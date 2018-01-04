class Api::ForecastsController < ApplicationController
  respond_to :json

  def index
    if new_version?
      data = time_periods.map do |time_period_row|
        if time_period_row[:data].nil?
          {quarter: time_period_row[:quarter]}
        else
          if user.present?
            NewForecastMemberSerializer.new(NewForecastMember.new(user, time_period_row[:data], product_family, product, time_period_row[:quarter], year))
          elsif team.present?
            NewForecastTeamSerializer.new(NewForecastTeam.new(team, time_period_row[:data], product_family, product, time_period_row[:quarter], year))
          elsif params[:team_id] == 'all'
            NewForecastSerializer.new(NewForecast.new(company, teams, time_period_row[:data], product_family, product, time_period_row[:quarter], year))
          elsif show_all_data
            NewForecastSerializer.new(NewForecast.new(company, teams, time_period_row[:data], product_family, product, time_period_row[:quarter], year))
          else
            NewForecastMemberSerializer.new(NewForecastMember.new(current_user, time_period_row[:data], product_family, product, time_period_row[:quarter], year))
          end
        end
      end
      render json: data
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
      render json: NewQuarterlyForecastSerializer.new(NewQuarterlyForecast.new(company, teams, team, user, time_period))
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
      render json: NewProductForecast.new(company, products, teams, team, user, time_period).forecasts_data
    else
      render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
    end
  end

  def pipeline_data
    render json: forecast_pipeline_data_serializer
  end

  def revenue_data
    render json: {
      revenue_data: forecast_revenue_data_serializer,
      pmp_revenue_data: forecast_pmp_revenue_data_serializer,
    }
  end

  def show
    render json: ForecastTeam.new(team, time_period.start_date, time_period.end_date, nil, year)
  end

  def run_forecast_calculation
    current_job = ForecastCalculationLog.find_by(company_id: current_user.company_id, finished: false)
    if current_job.present?
      render json: { error: "There is currently running forecast calculation job now." }, status: :unprocessable_entity
    else
      time_period_ids = company.time_periods.collect{|item| item.id},
      product_ids = company.products.collect{|item| item.id},
      user_ids = company.users.collect{|item| item.id}
      stage_ids = company.stages.collect{|item| item.id}
      deal_change = {time_period_ids: time_period_ids, product_ids: product_ids, stage_ids: stage_ids, user_ids: user_ids}
      io_change = {time_period_ids: time_period_ids, product_ids: product_ids, user_ids: user_ids}

      job = ForecastCalculationLog.create(company_id: current_user.company_id, start_date: DateTime.now, end_date: nil, finished: false)
      ForecastRevenueCalculatorWorker.perform_async(io_change)
      ForecastPipelineCalculatorWorker.perform_async(deal_change, current_user.company_id)

      render nothing: true
    end
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

  def time_periods
    return @time_periods if defined?(@time_periods)
    if params[:year]
      @time_periods = quarters.map do |quarter|
        {
          quarter: quarter[:quarter],
          data: company.time_periods.find_by(start_date: quarter[:start_date].to_date, end_date: quarter[:end_date].to_date)
        }
      end
    elsif params[:time_period_id]
      @time_periods = [{quarter: nil, data: company.time_periods.find(params[:time_period_id])}]
    else
      @time_period = [{quarter: nil, data: company.time_periods.now}]
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

  def product_family
    @_product_family ||= if params[:product_family_id] && params[:product_family_id] != 'all'
      company.product_families.find_by(id: params[:product_family_id])
    else
      nil
    end
  end

  def products
    @_products ||= if params[:product_ids] == ['all'] && params[:product_family_id] == 'all'
      company.products
    elsif params[:product_ids] && params[:product_ids] != ['all']
      company.products.where('id in (?)', params[:product_ids])
    elsif product_family
      product_family.products
    else
      []
    end
  end

  def user
    return @user if defined?(@user)
    @user = nil
    if params[:user_id] && params[:user_id] != 'all'
      @user = company.users.find(params[:user_id])
    end
  end  

  def company
    return @company if defined?(@company)
    @company = current_user.company
  end

  def show_all_data
    return company.forecast_permission[current_user.user_type.to_s]
  end

  def forecast_revenue_data_serializer
    Forecast::RevenueDataService.new(company, params).perform
  end

  def forecast_pmp_revenue_data_serializer
    Forecast::PmpRevenueDataService.new(company, params).perform
  end

  def forecast_pipeline_data_serializer
    Forecast::PipelineDataService.new(company, params).perform
  end

end
