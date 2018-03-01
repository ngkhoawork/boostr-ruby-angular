class NewForecastMember
  include ActiveModel::SerializerSupport

  delegate :id, to: :member
  delegate :name, to: :member

  attr_accessor :member,
    :time_period,
    :product_family,
    :product,
    :company,
    :start_date,
    :end_date,
    :quarter,
    :year

  def initialize(member, time_period, product_family = nil, product = nil, quarter = nil, year = nil)
    self.member = member
    self.company = member.company
    self.time_period = time_period
    self.start_date = time_period.start_date
    self.end_date = time_period.end_date
    self.product_family = product_family
    self.product = product
    self.quarter = quarter
    self.year = year
  end

  def is_leader
    member.leader?
  end

  def type
    'member'
  end

  def stages
    return @stages if defined?(@stages)
    ids = weighted_pipeline_by_stage.keys
    @stages = company.stages.where(id: ids).order(:probability).all.to_a
  end

  def forecast_time_dimension
    @_forecast_time_dimension ||= ForecastTimeDimension.find_by(id: time_period.id)
  end

  def pmp_revenue_data
    @_pmp_revenue_data ||= ForecastPmpRevenueFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids([member.id])
      .by_product_dimension_ids(product_ids)
      .select("SUM(amount) AS revenue_amount")
  end

  def revenue_data
    @_revenue_data ||= ForecastRevenueFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids([member.id])
      .by_product_dimension_ids(product_ids)
      .select("SUM(amount) AS revenue_amount")
  end

  def cost_revenue_data
    @_cost_revenue_data ||= ForecastCostFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids([member.id])
      .by_product_dimension_ids(product_ids)
      .select("SUM(amount) AS revenue_amount")
  end

  def pipeline_data
    @_pipeline_data ||= ForecastPipelineFact
      .joins("LEFT JOIN stages ON forecast_pipeline_facts.stage_dimension_id = stages.id")
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids([member.id])
      .by_product_dimension_ids(product_ids)
      .select("stages.id AS stage_id,
        SUM(forecast_pipeline_facts.amount) AS pipeline_amount,
        stages.probability as probability")
      .group("stages.id")
  end

  def pipeline_data_net
    @_pipeline_data_net ||= if company.enable_net_forecasting
      ForecastPipelineFact
        .joins("LEFT JOIN stages ON forecast_pipeline_facts.stage_dimension_id = stages.id")
        .joins("LEFT JOIN products ON forecast_pipeline_facts.product_dimension_id = products.id")
        .by_time_dimension_id(forecast_time_dimension.id)
        .by_user_dimension_ids([member.id])
        .by_product_dimension_ids(product_ids)
        .select("stages.id AS stage_id, 
          SUM(forecast_pipeline_facts.amount * products.margin / 100) AS pipeline_amount,
          stages.probability as probability")
        .group("stages.id")
    end
  end

  def forecasts_data
    return @forecasts_data if defined?(@forecasts_data)

    @forecasts_data = {
      stages: company.stages,
      product: product ? {
        id: product.id,
        name: product.name
      } : nil,
      revenue: 0.0,
      unweighted_pipeline_by_stage: {},
      unweighted_pipeline: 0.0,
      weighted_pipeline_by_stage: {},
      weighted_pipeline: 0.0,
      revenue_net: 0.0,
      unweighted_pipeline_by_stage_net: {},
      unweighted_pipeline_net: 0.0,
      weighted_pipeline_by_stage_net: {},
      weighted_pipeline_net: 0.0,
      quota: {}
    }

    revenue_data.each do |item|
      @forecasts_data[:revenue] = item.revenue_amount.to_f
      @forecasts_data[:revenue_net] = item.revenue_amount.to_f
    end

    pmp_revenue_data.each do |item|
      @forecasts_data[:revenue] += item.revenue_amount.to_f
      @forecasts_data[:revenue_net] += item.revenue_amount.to_f
    end

    if company.enable_net_forecasting
      cost_revenue_data.each do |item|
        @forecasts_data[:revenue_net] -= item.revenue_amount.to_f
      end
    end

    pipeline_data.each do |item|
      add_pipeline_data(item)
    end

    if pipeline_data_net
      pipeline_data_net.each do |item|
        add_pipeline_net_data(item)
      end
    end

    @forecasts_data
  end

  def add_pipeline_data(item)
    @forecasts_data[:unweighted_pipeline] += item.pipeline_amount.to_f
    @forecasts_data[:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
    @forecasts_data[:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount

    weighted_amount = item.pipeline_amount.to_f * item.probability.to_f / 100
    @forecasts_data[:weighted_pipeline] += weighted_amount
    @forecasts_data[:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
    @forecasts_data[:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
  end

  def add_pipeline_net_data(item)
    @forecasts_data[:unweighted_pipeline_net] += item.pipeline_amount.to_f
    @forecasts_data[:unweighted_pipeline_by_stage_net][item.stage_id] ||= 0.0
    @forecasts_data[:unweighted_pipeline_by_stage_net][item.stage_id] += item.pipeline_amount

    weighted_amount = item.pipeline_amount.to_f * item.probability.to_f / 100
    @forecasts_data[:weighted_pipeline_net] += weighted_amount
    @forecasts_data[:weighted_pipeline_by_stage_net][item.stage_id] ||= 0.0
    @forecasts_data[:weighted_pipeline_by_stage_net][item.stage_id] += weighted_amount
  end

  def weighted_pipeline
    return @weighted_pipeline if defined?(@weighted_pipeline)

    @weighted_pipeline = forecasts_data[:weighted_pipeline]
    @weighted_pipeline
  end

  def weighted_pipeline_by_stage
    return @weighted_pipeline_by_stage if defined?(@weighted_pipeline_by_stage)

    @weighted_pipeline_by_stage = forecasts_data[:weighted_pipeline_by_stage]
    @weighted_pipeline_by_stage
  end

  def unweighted_pipeline_by_stage
    return @unweighted_pipeline_by_stage if defined?(@unweighted_pipeline_by_stage)

    @unweighted_pipeline_by_stage = forecasts_data[:unweighted_pipeline_by_stage]
    @unweighted_pipeline_by_stage
  end

  def weighted_pipeline_net
    return @weighted_pipeline_net if defined?(@weighted_pipeline_net)

    @weighted_pipeline_net = forecasts_data[:weighted_pipeline_net]
    @weighted_pipeline_net
  end

  def weighted_pipeline_by_stage_net
    return @weighted_pipeline_by_stage_net if defined?(@weighted_pipeline_by_stage_net)

    @weighted_pipeline_by_stage_net = forecasts_data[:weighted_pipeline_by_stage_net]
    @weighted_pipeline_by_stage_net
  end

  def unweighted_pipeline_by_stage_net
    return @unweighted_pipeline_by_stage_net if defined?(@unweighted_pipeline_by_stage_net)

    @unweighted_pipeline_by_stage_net = forecasts_data[:unweighted_pipeline_by_stage_net]
    @unweighted_pipeline_by_stage_net
  end

  def revenue
    return @revenue if defined?(@revenue)

    @revenue = forecasts_data[:revenue]
    @revenue
  end

  def revenue_net
    return @revenue_net if defined?(@revenue_net)

    @revenue_net = forecasts_data[:revenue_net]
    @revenue_net
  end

  def wow_weighted_pipeline
    snapshots.first.weighted_pipeline - snapshots.last.weighted_pipeline rescue 0
  end

  def wow_revenue
    snapshots.first.revenue - snapshots.last.revenue rescue 0
  end

  def amount
    @amount ||= weighted_pipeline + revenue
  end

  def amount_net
    @amount_net ||= weighted_pipeline_net + revenue_net
  end

  def percent_to_quota
    # attainment
    return 100 unless quota > 0
    amount / quota * 100
  end

  def percent_to_quota_net
    # attainment
    return 100 unless quota > 0
    amount_net / quota * 100
  end

  def percent_booked
    # attainment
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def percent_booked_net
    # attainment
    return 100 unless quota > 0
    revenue_net / quota * 100
  end

  def gap_to_quota
    if company.forecast_gap_to_quota_positive
      return (quota - amount).to_f
    else
      return (amount - quota).to_f
    end
  end

  def gap_to_quota_net
    if company.forecast_gap_to_quota_positive
      return (quota - amount_net).to_f
    else
      return (amount_net - quota).to_f
    end
  end

  def quota
    @quota ||= member.total_gross_quotas(start_date, end_date)
  end

  def win_rate
    if (incomplete_deals.count + complete_deals.count) > 0
      @win_rate ||= (complete_deals.count.to_f / (complete_deals.count.to_f + incomplete_deals.count.to_f))
    else
      @win_rate ||= 0.0
    end
  end

  def average_deal_size
    if complete_deals.count > 0
      @average_deal_size ||= complete_deals.average(:budget).round(0)
    else
      @average_deal_size ||= 0
    end
  end

  def new_deals_needed
    goal = gap_to_quota
    return 0 if goal <= 0 && company.forecast_gap_to_quota_positive
    return 0 if goal > 0 && !company.forecast_gap_to_quota_positive
    return 'N/A' if average_deal_size <= 0 or win_rate <= 0
    (gap_to_quota.abs / (win_rate * average_deal_size)).ceil
  end

  private

  def client_ids
    @client_ids ||= member.client_members.map(&:client_id)
  end

  def revenues
    @revenues ||= company.revenues.where(client_id: client_ids).for_time_period(start_date, end_date).to_a
  end

  def ios
    @ios ||= member.ios.for_time_period(start_date, end_date).to_a
  end

  def product_ids
    @_product_ids ||= if product.present?
      [product.id]
    elsif product_family.present?
      product_family.products.collect(&:id)
    end
  end

  def clients
    self.member.clients
  end

  def open_deals
    @open_deals ||= member.deals.where(open: true).for_time_period(start_date, end_date).includes(:deal_product_budgets, :stage).to_a
  end

  def complete_deals
    @complete_deals ||= member.deals.active.at_percent(100).closed_in(company.deals_needed_calculation_duration)
  end

  def incomplete_deals
    @incomplete_deals ||= member.deals.active.closed.at_percent(0).closed_in(company.deals_needed_calculation_duration)
  end

  def snapshots
    @snapshots ||= member.snapshots.two_recent_for_time_period(start_date, end_date)
  end

  def months
    return @months if defined?(@months)

    @months = (start_date.to_date..end_date.to_date).map { |d| { start_date: d.beginning_of_month, end_date: d.end_of_month } }.uniq
    @months
  end

  def quarters
    return @quarters if defined?(@quarters)
    @quarters = (start_date.to_date..end_date.to_date).map { |d| { start_date: d.beginning_of_quarter, end_date: d.end_of_quarter } }.uniq
    @quarters
  end
end
