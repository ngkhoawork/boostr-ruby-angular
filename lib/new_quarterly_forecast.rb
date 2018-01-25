class NewQuarterlyForecast
  include ActiveModel::SerializerSupport

  delegate :id, to: :company

  attr_accessor :company, :teams, :team, :user, :time_period

  # If there is a year, the start_date and end_date are ignored
  def initialize(company, teams, team, user, time_period)
    self.company = company
    self.teams = teams
    self.team = team
    self.user = user
    self.time_period = time_period
  end  

  def forecasts_data
    return @data if defined?(@data)

    start_date = time_period.start_date
    end_date = time_period.end_date
    forecast_time_dimension = ForecastTimeDimension.find_by(id: time_period.id)
    @data = {
      forecast: {
        stages: [],
        quarterly_revenue: {},
        quarterly_unweighted_pipeline_by_stage: {},
        quarterly_weighted_pipeline_by_stage: {},
        quarterly_quota: {}
      },
      quarters: []
    }

    month_to_quarter = {}
    (start_date.to_date..end_date.to_date).each do |d|
      month_index = d.strftime("%b-%y")
      month_to_quarter[month_index] = 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s
    end
    user_ids = []
    if user.present?
      user_ids << user.id
      @data[:forecast][:id] = user.id
      @data[:forecast][:name] = user.name
      @data[:forecast][:type] = 'member'
    elsif team.present?
      user_ids = team.all_members.map{|user| user.id} + team.all_leaders.map{|user| user.id}
      user_ids.uniq!
      leader = team.leader
      @data[:forecast][:id] = team.id
      @data[:forecast][:name] = team.name
      @data[:forecast][:type] = 'team'
    else
      teams.each do |team_item|
        user_ids += team_item.all_members.map{|user| user.id} + team_item.all_leaders.map{|user| user.id}
      end
      user_ids.uniq!
    end

    @data[:forecast][:quarterly_quota] = quarterly_quota
    
    @data[:quarters] = (start_date.to_date..end_date.to_date).map { |d| 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s }.uniq    

    return @data if user_ids.empty?

    pipeline_sql = "SELECT stage_dimension_id AS stage_id, avg(s.total) AS pipeline_amount, json_object_agg(key, val) AS monthly_amount
      FROM (
          SELECT stage_dimension_id, SUM(amount) AS total, key, SUM(value::numeric) AS val
          FROM forecast_pipeline_facts t, jsonb_each_text(monthly_amount)
          WHERE  forecast_time_dimension_id = #{forecast_time_dimension.id} AND user_dimension_id IN (#{user_ids.count > 0 ? user_ids.join(', ') : 0})
          GROUP BY stage_dimension_id, key
          ) s
      GROUP BY stage_dimension_id"
    pipeline_data = ActiveRecord::Base.connection.execute(pipeline_sql)
    revenue_sql = "SELECT avg(s.total) AS revenue_amount, json_object_agg(key, val) AS monthly_amount " +
      "FROM ( " +
          "SELECT SUM(amount) AS total, key, SUM(value::numeric) AS val " +
          "FROM forecast_revenue_facts t, jsonb_each_text(monthly_amount) " +
          "WHERE  forecast_time_dimension_id = #{forecast_time_dimension.id} AND user_dimension_id IN (#{user_ids.join(', ')}) " +
          "GROUP BY key " +
          ") s "
    revenue_data = ActiveRecord::Base.connection.execute(revenue_sql)

    revenue_data.each do |revenue_row|
      if revenue_row['monthly_amount']
        JSON.parse(revenue_row['monthly_amount']).each do |month_index, amount|
          quarter = month_to_quarter[month_index]
          @data[:forecast][:quarterly_revenue][quarter] ||= 0
          @data[:forecast][:quarterly_revenue][quarter] += amount.to_f
        end
      end
    end
    stage_ids = []
    pipeline_data.each do |pipeline_row|
      stage_id = pipeline_row['stage_id']
      stage_item = company.stages.find_by(id: stage_id)
      next if stage_item.nil?
      probability = stage_item.probability.to_f
      @data[:forecast][:quarterly_unweighted_pipeline_by_stage][stage_id] ||= {}
      @data[:forecast][:quarterly_weighted_pipeline_by_stage][stage_id] ||= {}
      stage_ids << stage_item.id
      JSON.parse(pipeline_row['monthly_amount']).each do |month_index, amount|
        quarter = month_to_quarter[month_index]
        @data[:forecast][:quarterly_unweighted_pipeline_by_stage][stage_id][quarter] ||= 0
        @data[:forecast][:quarterly_weighted_pipeline_by_stage][stage_id][quarter] ||= 0
        @data[:forecast][:quarterly_unweighted_pipeline_by_stage][stage_id][quarter] += amount.to_f
        @data[:forecast][:quarterly_weighted_pipeline_by_stage][stage_id][quarter] += amount.to_f * probability / 100.0
      end
    end

    stage_ids = stage_ids.uniq
    @data[:forecast][:stages] = company.stages.where(id: stage_ids).order(:probability).all

    @data
  end

  def forecast
    return @forecast if defined?(@forecast)

    @forecast = forecasts_data[:forecast]
    @forecast
  end

  def quarterly_quota
    return @quarterly_quota if defined?(@quarterly_quota)
    start_date = time_period.start_date
    end_date = time_period.end_date
    quarters = (start_date.to_date..end_date.to_date).map { |d| { start_date: d.beginning_of_quarter, end_date: d.end_of_quarter } }.uniq
    @quarterly_quota = {}
    
    if user.present?
      quarters.each do |quarter_row|
        @quarterly_quota['q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s] = user.total_gross_quotas(quarter_row[:start_date], quarter_row[:end_date])
      end
    elsif team.present?
      leader = team.leader
      quarters.each do |quarter_row|
        quarter = 'q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s
        @quarterly_quota[quarter] ||= 0
        if leader.present?
          @quarterly_quota[quarter] += leader.total_gross_quotas(quarter_row[:start_date], quarter_row[:end_date])
        end
      end
    else
      teams.each do |team_item|
        leader = team_item.leader
        quarters.each do |quarter_row|
          quarter = 'q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s
          @quarterly_quota[quarter] ||= 0
          if leader.present?
            @quarterly_quota[quarter] += leader.total_gross_quotas(quarter_row[:start_date], quarter_row[:end_date])
          end
        end
      end
    end
    @quarterly_quota
  end

  def quarters
    return @quarters_data if defined?(@quarters_data)

    @quarters_data = forecasts_data[:quarters]
    @quarters_data
  end
end
