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

    start_date = time_period.start_date
    end_date = time_period.end_date
    forecast_time_dimension = ForecastTimeDimension.find_by(id: time_period.id)

    user_ids = []
    if user.present?
      user_ids << user.id
    elsif team.present?
      user_ids = team.all_members.map{|user| user.id} + team.all_leaders.map{|user| user.id}
      user_ids.uniq!
    else
      teams.each do |team_item|
        user_ids += team_item.all_members.map{|user| user.id} + team_item.all_leaders.map{|user| user.id}
      end
      user_ids.uniq!
    end
    product_ids = []
    data = {}
    stages = company.stages
    products.each do |product_item|
      product_ids << product_item.id
      data[product_item.id] = {
        product: {
          id: product_item.id,
          name: product_item.name
        },
        stages: stages,
        revenue: 0.0,
        unweighted_pipeline_by_stage: {},
        weighted_pipeline_by_stage: {},
        unweighted_pipeline: 0.0,
        weighted_pipeline: 0.0
      }
    end

    revenue_data = ForecastRevenueFact.where("forecast_time_dimension_id = ? AND user_dimension_id IN (?) AND product_dimension_id IN (?)", forecast_time_dimension.id, user_ids, product_ids)
      .select("product_dimension_id AS product_id, SUM(amount) AS revenue_amount")
      .group("product_dimension_id")
      .each do |item|
        data[item.product_id]['revenue'] = item.revenue_amount.to_f
      end
    pipeline_data = ForecastPipelineFact.where("forecast_time_dimension_id = ? AND user_dimension_id IN (?) AND product_dimension_id IN (?)", forecast_time_dimension.id, user_ids, product_ids)
      .select("product_dimension_id AS product_id, stage_dimension_id AS stage_id, SUM(amount) AS pipeline_amount")
      .group("product_dimension_id, stage_dimension_id")
      .each do |item|
        data[item.product_id][:unweighted_pipeline] += item.pipeline_amount.to_f
        data[item.product_id][:unweighted_pipeline_by_stage][item.stage_id] ||= 0.0
        data[item.product_id][:unweighted_pipeline_by_stage][item.stage_id] += item.pipeline_amount

        weighted_amount = item.pipeline_amount.to_f * company.stages.find(item.stage_id).probability.to_f / 100
        data[item.product_id][:weighted_pipeline] += weighted_amount
        data[item.product_id][:weighted_pipeline_by_stage][item.stage_id] ||= 0.0
        data[item.product_id][:weighted_pipeline_by_stage][item.stage_id] += weighted_amount
      end
    @forecasts_data = data.map{|index, item| item}
    @forecasts_data
  end
end
