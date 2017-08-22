class Api::ForecastsController < ApplicationController
  respond_to :json

  def index
    if new_version?
      if user.present?
        render json: forecast_member
      elsif team.present?
        render json: [NewForecastTeam.new(team, time_period, product)]
      elsif params[:team_id] == 'all'
        render json: [NewForecast.new(company, teams, time_period, product)]
      elsif show_all_data
        render json: [NewForecast.new(company, teams, time_period, product)]
      else
        render json: forecast_member
      end
    else
      if user.present?
        render json: forecast_member
      elsif team.present?
        render json: [ForecastTeam.new(team, time_period.start_date, time_period.end_date, year)]
      elsif params[:id] == 'all'
        render json: [Forecast.new(company, teams, time_period.start_date, time_period.end_date, year)]
      elsif show_all_data
        render json: [Forecast.new(company, teams, time_period.start_date, time_period.end_date, year)]
      else
        render json: forecast_member
      end
    end
  end

  def detail
    if valid_time_period?
      
      start_date = time_period.start_date
      end_date = time_period.end_date
      forecast_time_dimension = ForecastTimeDimension.find_by(id: time_period.id)
      data = {
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
        data[:forecast][:id] = user.id
        data[:forecast][:name] = user.name
        data[:forecast][:type] = 'member'
      elsif team.present?
        user_ids = team.all_members.map{|user| user.id} + team.all_leaders.map{|user| user.id}
        user_ids.uniq!
        leader = team.leader
        data[:forecast][:id] = team.id
        data[:forecast][:name] = team.name
        data[:forecast][:type] = 'team'
      else
        teams.each do |team_item|
          user_ids += team_item.all_members.map{|user| user.id} + team_item.all_leaders.map{|user| user.id}
        end
        user_ids.uniq!
      end
      
      pipeline_sql = "SELECT stage_dimension_id AS stage_id, avg(s.total) AS pipeline_amount, json_object_agg(key, val) AS monthly_amount
        FROM (
            SELECT stage_dimension_id, SUM(amount) AS total, key, SUM(value::numeric) AS val
            FROM forecast_pipeline_facts t, jsonb_each_text(monthly_amount)
            WHERE  forecast_time_dimension_id = #{forecast_time_dimension.id} AND user_dimension_id IN (#{user_ids.join(', ')})
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
            data[:forecast][:quarterly_revenue][quarter] ||= 0
            data[:forecast][:quarterly_revenue][quarter] += amount.to_f
          end
        end
      end
      stage_ids = []
      pipeline_data.each do |pipeline_row|
        stage_id = pipeline_row['stage_id']
        stage_item = company.stages.find_by(id: stage_id)
        next if stage_item.nil?
        probability = stage_item.probability.to_f
        data[:forecast][:quarterly_unweighted_pipeline_by_stage][stage_id] ||= {}
        data[:forecast][:quarterly_weighted_pipeline_by_stage][stage_id] ||= {}
        stage_ids << stage_item.id
        JSON.parse(pipeline_row['monthly_amount']).each do |month_index, amount|
          quarter = month_to_quarter[month_index]
          data[:forecast][:quarterly_unweighted_pipeline_by_stage][stage_id][quarter] ||= 0
          data[:forecast][:quarterly_weighted_pipeline_by_stage][stage_id][quarter] ||= 0
          data[:forecast][:quarterly_unweighted_pipeline_by_stage][stage_id][quarter] += amount.to_f
          data[:forecast][:quarterly_weighted_pipeline_by_stage][stage_id][quarter] += amount.to_f * probability / 100.0
        end
      end


      stage_ids = stage_ids.uniq
      data[:forecast][:stages] = company.stages.where(id: stage_ids).order(:probability).all

      data[:forecast][:quarterly_quota] = quarterly_quota
      data[:quarters] = (start_date.to_date..end_date.to_date).map { |d| 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s }.uniq
      
      render json: data
    else
      render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
    end
  end

  def old_detail
    if valid_time_period?
      start_date = time_period.start_date
      end_date = time_period.end_date

      quarters = (start_date.to_date..end_date.to_date).map { |d| 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s }.uniq
      if user.present?
        render json: { forecast: QuarterlyForecastMemberSerializer.new(ForecastMember.new(user, start_date, end_date, nil, nil)), quarters: quarters }
        
      elsif team.present?
        render json: { forecast: QuarterlyForecastTeamSerializer.new(ForecastTeam.new(team, start_date, end_date, nil, nil)), quarters: quarters }
      else
        render json: { forecast: QuarterlyForecastSerializer.new(Forecast.new(company, teams, start_date, end_date, nil)), quarters: quarters }
      end
    else
      render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
    end
  end

  def old_product_detail
    if valid_time_period?
      start_date = time_period.start_date
      end_date = time_period.end_date

      quarters = (start_date.to_date..end_date.to_date).map { |d| 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s }.uniq
      if user.present?
        data = products.map do |product_item|
          ProductForecastMemberSerializer.new(ProductForecastMember.new(user, product_item, start_date, end_date, nil, nil))
        end
        render json: data
        
      elsif team.present?
        data = products.map do |product_item|
          ProductForecastTeamSerializer.new(ProductForecastTeam.new(team, product_item, start_date, end_date, nil, nil))
        end
        render json: data
      else
        data = products.map do |product_item|
          ProductForecastSerializer.new(ProductForecast.new(company, teams, product_item, start_date, end_date, nil))
        end
        render json: data
      end
    else
      render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
    end
  end

  def product_detail
    if valid_time_period?
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
      render json: data.map{|index, item| item}
    else
      render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
    end
  end

  def show
    render json: ForecastTeam.new(team, time_period.start_date, time_period.end_date, nil, year)
  end

  def run_forecast_calculation
    time_period_ids = company.time_periods.collect{|item| item.id},
    product_ids = company.products.collect{|item| item.id},
    user_ids = company.users.collect{|item| item.id}
    stage_ids = company.stages.collect{|item| item.id}
    deal_change = {time_period_ids: time_period_ids, product_ids: product_ids, stage_ids: stage_ids, user_ids: user_ids}
    io_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids}

    ForecastRevenueCalculatorWorker.perform_async(io_change)
    ForecastPipelineCalculatorWorker.perform_async(deal_change)

    render nothing: true
  end

  protected

  def forecast_member
    if year
      quarters.map do |dates|
        ForecastMember.new(current_user, dates[:start_date], dates[:end_date], dates[:quarter], year)
      end
    else
      if new_version?
        if user.present?
          [NewForecastMember.new(user, time_period, product)]
        else
          [NewForecastMember.new(current_user, time_period, product)]
        end
      else
        if user.present?
          [ForecastMember.new(user, time_period.start_date, time_period.end_date)]
        else
          [ForecastMember.new(current_user, time_period.start_date, time_period.end_date)]
        end
      end
    end
  end

  def new_version?
    params[:new_version] && params[:new_version] == 'true'
  end

  def year
    return nil if params[:year].to_i < 2000

    params[:year].to_i
  end

  def quarters
    return @quarters if defined?(@quarters)

    @quarters = []
    @quarters << { start_date: Time.new(year, 1, 1), end_date: Time.new(year, 3, 31), quarter: 1 }
    @quarters << { start_date: Time.new(year, 4, 1), end_date: Time.new(year, 6, 30), quarter: 2 }
    @quarters << { start_date: Time.new(year, 7, 1), end_date: Time.new(year, 9, 30), quarter: 3 }
    @quarters << { start_date: Time.new(year, 10, 1), end_date: Time.new(year, 12, 31), quarter: 4 }
    @quarters
  end

  def time_period
    return @time_period if defined?(@time_period)

    if params[:time_period_id]
      @time_period = company.time_periods.find(params[:time_period_id])
    else
      @time_period = company.time_periods.now
    end
  end

  def valid_time_period?
    if params[:time_period_id].present? && time_period.present?
      if time_period.start_date == time_period.start_date.beginning_of_year && time_period.end_date == time_period.start_date.end_of_year
        return true
      elsif time_period.start_date == time_period.start_date.beginning_of_quarter && time_period.end_date == time_period.start_date.end_of_quarter
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def teams
    return @teams if defined?(@teams)
    @teams = company.teams.roots(true)
  end

  def team
    return @team if defined?(@team)
    @team = nil
    if params[:team_id] && params[:team_id] != 'all'
      @team = company.teams.find(params[:team_id])
    elsif params[:id] && params[:id] != 'all'
      @team = company.teams.find(params[:id])
    end
  end

  def product
    return @product if defined?(@product)
    @product = nil
    if params[:product_id] && params[:product_id] != 'all'
      @product = company.products.find(params[:product_id])
    end
  end

  def products
    return @products if defined?(@products)
    @products = []
    if params[:product_ids] == ['all']
      @products = company.products
    elsif params[:product_ids] && params[:product_ids] != ['all']
      @products = company.products.where('id in (?)', params[:product_ids])
    end
  end

  def user
    return @user if defined?(@user)
    @user = nil
    if params[:user_id] && params[:user_id] != 'all'
      @user = company.users.find(params[:user_id])
    end
  end

  def quarterly_quota
    return @quarterly_quota if defined?(@quarterly_quota)
    start_date = time_period.start_date
    end_date = time_period.end_date
    @quarters = (start_date.to_date..end_date.to_date).map { |d| { start_date: d.beginning_of_quarter, end_date: d.end_of_quarter } }.uniq
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

  def company
    return @company if defined?(@company)
    @company = current_user.company
  end

  def show_all_data
    return company.forecast_permission[current_user.user_type.to_s]
  end

end
