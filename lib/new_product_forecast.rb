class NewProductForecast
  include ActiveModel::SerializerSupport

  delegate :id, to: :company

  attr_accessor :company, :products, :teams, :team, :user, :time_period

  # If there is a year, the start_date and end_date are ignored
  def initialize(company, products, teams, team, user, time_period)
    self.company = company
    self.teams = teams
    self.team = team
    self.user = user
    self.products = products
    self.time_period = time_period
  end

  def forecasts_data
    return @forecasts_data if defined?(@forecasts_data)

    data = init_data
    revenue_data.each do |item|
      data[item.product_id]['revenue'] = item.revenue_amount.to_f
      data[item.product_id]['revenue_net'] = item.revenue_amount.to_f
    end

    pmp_revenue_data.each do |item|
      data[item.product_id]['revenue'] ||= 0
      data[item.product_id]['revenue'] += item.revenue_amount.to_f
      data[item.product_id]['revenue_net'] ||= 0
      data[item.product_id]['revenue_net'] += item.revenue_amount.to_f
    end

    if company.enable_net_forecasting
      cost_revenue_data.each do |item|
        data[item.product_id]['revenue_net'] ||= 0
        data[item.product_id]['revenue_net'] -= item.revenue_amount.to_f
      end
    end

    pipeline_data.each do |item|
      add_pipeline_data(data, item)
    end

    if pipeline_data_net
      pipeline_data_net.each do |item|
        add_pipeline_net_data(data, item)
      end
    end

    @forecasts_data = data.values
  end

  def add_pipeline_data(data, item)
    data[item.product_id][:unweighted_pipeline] += item.pipeline_amount.to_f
    data[item.product_id][:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
    data[item.product_id][:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount.to_f

    weighted_amount = item.pipeline_amount.to_f * item.probability.to_f / 100
    data[item.product_id][:weighted_pipeline] += weighted_amount
    data[item.product_id][:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
    data[item.product_id][:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
  end

  def add_pipeline_net_data(data, item)
    data[item.product_id][:unweighted_pipeline_net] += item.pipeline_amount.to_f
    data[item.product_id][:unweighted_pipeline_by_stage_net][item.stage_id] ||= 0.0
    data[item.product_id][:unweighted_pipeline_by_stage_net][item.stage_id] += item.pipeline_amount.to_f

    weighted_amount = item.pipeline_amount.to_f * item.probability.to_f / 100
    data[item.product_id][:weighted_pipeline_net] += weighted_amount
    data[item.product_id][:weighted_pipeline_by_stage_net][item.stage_id] ||= 0.0
    data[item.product_id][:weighted_pipeline_by_stage_net][item.stage_id] += weighted_amount
  end

  def init_data
    @_init_data ||= products.inject({}) do |result, product_item|
      result[product_item.id] = {
        product: ProductSerializer.new(product_item),
        stages: stages,
        revenue: 0.0,
        unweighted_pipeline_by_stage: {},
        weighted_pipeline_by_stage: {},
        unweighted_pipeline: 0.0,
        weighted_pipeline: 0.0,
        revenue_net: 0.0,
        unweighted_pipeline_by_stage_net: {},
        weighted_pipeline_by_stage_net: {},
        unweighted_pipeline_net: 0.0,
        weighted_pipeline_net: 0.0
      }
      result
    end
  end

  def start_date
    @_start_date ||= time_period.start_date
  end

  def end_date
    @_end_date ||= time_period.end_date
  end

  def forecast_time_dimension
    @_forecast_time_dimension ||= ForecastTimeDimension.find_by(id: time_period.id)
  end

  def stages
    @_stages ||= company.stages
  end

  def product_ids
    @_product_ids ||= products.map(&:id)
  end

  def user_ids
    @_user_ids ||= if user.present?
      [user.id]
    elsif team.present?
      (team.all_members.map(&:id) + team.all_leaders.map(&:id)).uniq
    else
      teams.inject([]) do |result, team_item|
        result += team_item.all_members.map(&:id) + team_item.all_leaders.map(&:id)
      end.uniq
    end
  end

  def revenue_data
    @_revenue_data ||= ForecastRevenueFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("product_dimension_id AS product_id, SUM(amount) AS revenue_amount")
      .group("product_dimension_id")
  end

  def cost_revenue_data
    @_cost_revenue_data ||= ForecastCostFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("product_dimension_id AS product_id, SUM(amount) AS revenue_amount")
      .group("product_dimension_id")
  end

  def pmp_revenue_data
    @_pmp_revenue_data ||= ForecastPmpRevenueFact
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("product_dimension_id AS product_id, SUM(amount) AS revenue_amount")
      .group("product_dimension_id")
  end

  def pipeline_data
    @_pipeline_data ||= ForecastPipelineFact
      .joins("LEFT JOIN stages ON forecast_pipeline_facts.stage_dimension_id = stages.id")
      .by_time_dimension_id(forecast_time_dimension.id)
      .by_user_dimension_ids(user_ids)
      .by_product_dimension_ids(product_ids)
      .select("forecast_pipeline_facts.product_dimension_id AS product_id,
        stages.id AS stage_id,
        SUM(forecast_pipeline_facts.amount) AS pipeline_amount,
        stages.probability as probability")
      .group("forecast_pipeline_facts.product_dimension_id,
        stages.id")
  end

  def pipeline_data_net
    @_pipeline_data_net ||= if company.enable_net_forecasting
      ForecastPipelineFact
        .joins("LEFT JOIN stages ON forecast_pipeline_facts.stage_dimension_id = stages.id")
        .joins("LEFT JOIN products ON forecast_pipeline_facts.product_dimension_id = products.id")
        .by_time_dimension_id(forecast_time_dimension.id)
        .by_user_dimension_ids(user_ids)
        .by_product_dimension_ids(product_ids)
        .select("forecast_pipeline_facts.product_dimension_id AS product_id,
          stages.id AS stage_id,
          SUM(forecast_pipeline_facts.amount * products.margin / 100) AS pipeline_amount,
          stages.probability as probability")
        .group("forecast_pipeline_facts.product_dimension_id,
          stages.id")
    end
  end
end
