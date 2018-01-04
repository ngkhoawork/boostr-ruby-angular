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

    @data = initial_data
    
    return @data if user_ids.empty?

    revenue_data.each do |revenue_row|
      if revenue_row['monthly_amount']
        JSON.parse(revenue_row['monthly_amount']).each do |month_index, amount|
          quarter = month_to_quarter[month_index]
          @data[:forecast][:quarterly_revenue][quarter] ||= 0
          @data[:forecast][:quarterly_revenue][quarter] += amount.to_f
        end
      end
    end
    pmp_revenue_data.each do |revenue_row|
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

  def pipeline_sql
    @_pipeline_sql ||= "SELECT stage_dimension_id AS stage_id, avg(s.total) AS pipeline_amount, json_object_agg(key, val) AS monthly_amount
      FROM (
          SELECT stage_dimension_id, SUM(amount) AS total, key, SUM(value::numeric) AS val
          FROM forecast_pipeline_facts t, jsonb_each_text(monthly_amount)
          WHERE  forecast_time_dimension_id = #{forecast_time_dimension.id} AND user_dimension_id IN (#{user_ids.count > 0 ? user_ids.join(', ') : 0})
          GROUP BY stage_dimension_id, key
          ) s
      GROUP BY stage_dimension_id"
  end

  def revenue_sql
    @_revenue_sql ||= "SELECT avg(s.total) AS revenue_amount, json_object_agg(key, val) AS monthly_amount " +
      "FROM ( " +
          "SELECT SUM(amount) AS total, key, SUM(value::numeric) AS val " +
          "FROM forecast_revenue_facts t, jsonb_each_text(monthly_amount) " +
          "WHERE  forecast_time_dimension_id = #{forecast_time_dimension.id} AND user_dimension_id IN (#{user_ids.join(', ')}) " +
          "GROUP BY key " +
          ") s "
  end

  def pmp_revenue_sql
    @_pmp_revenue_sql ||= "SELECT avg(s.total) AS revenue_amount, json_object_agg(key, val) AS monthly_amount " +
      "FROM ( " +
          "SELECT SUM(amount) AS total, key, SUM(value::numeric) AS val " +
          "FROM forecast_pmp_revenue_facts t, jsonb_each_text(monthly_amount) " +
          "WHERE  forecast_time_dimension_id = #{forecast_time_dimension.id} AND user_dimension_id IN (#{user_ids.join(', ')}) " +
          "GROUP BY key " +
          ") s "
  end

  def pipeline_data
    @_pipeline_data ||= ActiveRecord::Base.connection.execute(pipeline_sql)
  end

  def revenue_data
    @_revenue_data ||= ActiveRecord::Base.connection.execute(revenue_sql)
  end

  def pmp_revenue_data
    puts "=============pmp revenue"
    @_pmp_revenue_data ||= ActiveRecord::Base.connection.execute(pmp_revenue_sql)
  end

  def forecast
    return @forecast if defined?(@forecast)

    @forecast = forecasts_data[:forecast]
    @forecast
  end

  def month_to_quarter
    @_month_to_quarter ||= (start_date.to_date..end_date.to_date)
      .inject({}) do |result, d|
        month_index = d.strftime("%b-%y")
        result[month_index] = 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s
        result
      end
  end

  def quarterly_quota
    return @quarterly_quota if defined?(@quarterly_quota)
    start_date = time_period.start_date
    end_date = time_period.end_date
    quarters = (start_date.to_date..end_date.to_date).map { |d| { start_date: d.beginning_of_quarter, end_date: d.end_of_quarter } }.uniq
    @quarterly_quota = {}
    
    if user.present?
      quarters.each do |quarter_row|
        @quarterly_quota['q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s] = user.quotas.for_time_period(quarter_row[:start_date], quarter_row[:end_date]).sum(:value)
      end
    elsif team.present?
      leader = team.leader
      quarters.each do |quarter_row|
        quarter = 'q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s
        @quarterly_quota[quarter] ||= 0
        if leader.present?
          @quarterly_quota[quarter] += leader.quotas.for_time_period(quarter_row[:start_date], quarter_row[:end_date]).sum(:value)
        end
      end
    else
      teams.each do |team_item|
        leader = team_item.leader
        quarters.each do |quarter_row|
          quarter = 'q' + ((quarter_row[:start_date].month - 1) / 3 + 1).to_s + '-' + quarter_row[:start_date].year.to_s
          @quarterly_quota[quarter] ||= 0
          if leader.present?
            @quarterly_quota[quarter] += leader.quotas.for_time_period(quarter_row[:start_date], quarter_row[:end_date]).sum(:value)
          end
        end
      end
    end
    @quarterly_quota
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

  def initial_data
    data = {
      forecast: {
        stages: [],
        quarterly_revenue: {},
        quarterly_unweighted_pipeline_by_stage: {},
        quarterly_weighted_pipeline_by_stage: {},
        quarterly_quota: quarterly_quota
      },
      quarters: (start_date.to_date..end_date.to_date)
        .map { |d| 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s }
        .uniq
    }

    if user.present?
      data[:forecast][:id] = user.id
      data[:forecast][:name] = user.name
      data[:forecast][:type] = 'member'
    elsif team.present?
      data[:forecast][:id] = team.id
      data[:forecast][:name] = team.name
      data[:forecast][:type] = 'team'
    end

    data
  end

  def user_ids
    @_user_ids ||= if user.present?
      user_ids = [user.id]
    elsif team.present?
      user_ids = team.all_members.map{|user| user.id} + team.all_leaders.map{|user| user.id}
      user_ids.uniq
    else
      teams.inject([]) do |result, team_item|
        result += team_item.all_members.map{|user| user.id} + team_item.all_leaders.map{|user| user.id}
      end.uniq
    end
  end

  def leader
    @_leader ||= if team.present?
      team.leader
    end
  end

  def quarters
    return @quarters_data if defined?(@quarters_data)

    @quarters_data = forecasts_data[:quarters]
    @quarters_data
  end
end
