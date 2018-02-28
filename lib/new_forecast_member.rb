class NewForecastMember
  include ActiveModel::SerializerSupport

  delegate :id, to: :member
  delegate :name, to: :member

  attr_accessor :member, :time_period, :product_family, :product, :start_date, :end_date, :quarter, :year

  def initialize(member, time_period, product_family = nil, product = nil, quarter = nil, year = nil)
    self.member = member
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
    @stages = member.company.stages.where(id: ids).order(:probability).all.to_a
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

  def pipeline_data
    @_pipeline_data ||= ForecastPipelineFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids([member.id])
      .by_product_dimension_ids(product_ids)
      .select("stage_dimension_id AS stage_id, SUM(amount) AS pipeline_amount")
      .group("stage_dimension_id")
  end

  def forecasts_data
    return @forecasts_data if defined?(@forecasts_data)

    company = member.company

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
      quota: {}
    }

    revenue_data.each do |item|
      @forecasts_data[:revenue] = item.revenue_amount.to_f
    end

    pmp_revenue_data.each do |item|
      @forecasts_data[:revenue] += item.revenue_amount.to_f
    end

    pipeline_data.each do |item|
      @forecasts_data[:unweighted_pipeline] += item.pipeline_amount.to_f
      @forecasts_data[:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
      @forecasts_data[:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount

      weighted_amount = item.pipeline_amount.to_f * company.stages.find(item.stage_id).probability.to_f / 100
      @forecasts_data[:weighted_pipeline] += weighted_amount
      @forecasts_data[:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
      @forecasts_data[:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
    end

    @forecasts_data
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


  def revenue
    return @revenue if defined?(@revenue)

    @revenue = forecasts_data[:revenue]
    @revenue
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

  def percent_to_quota
    # attainment
    return 100 unless quota > 0
    amount / quota * 100
  end

  def percent_booked
    # attainment
    return 100 unless quota > 0
    revenue / quota * 100
  end

  def gap_to_quota
    if member.company.forecast_gap_to_quota_positive
      return (quota - amount).to_f
    else
      return (amount - quota).to_f
    end
  end

  def quota
    @quota ||= member.quotas.for_time_period(start_date, end_date).sum(:value)
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
    return 0 if goal <= 0 && member.company.forecast_gap_to_quota_positive
    return 0 if goal > 0 && !member.company.forecast_gap_to_quota_positive
    return 'N/A' if average_deal_size <= 0 or win_rate <= 0
    (gap_to_quota.abs / (win_rate * average_deal_size)).ceil
  end

  private

  def client_ids
    @client_ids ||= member.client_members.map(&:client_id)
  end

  def revenues
    @revenues ||= member.company.revenues.where(client_id: client_ids).for_time_period(start_date, end_date).to_a
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
    @complete_deals ||= member.deals.active.at_percent(100).closed_in(member.company.deals_needed_calculation_duration)
  end

  def incomplete_deals
    @incomplete_deals ||= member.deals.active.closed.at_percent(0).closed_in(member.company.deals_needed_calculation_duration)
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
