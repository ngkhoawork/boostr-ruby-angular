class Api::ForecastsController < ApplicationController
  respond_to :json

  def index
    if user.present?
      render json: forecast_member
    elsif team.present?
      render json: [ForecastTeam.new(team, time_period.start_date, time_period.end_date)]
    elsif params[:id] == 'all'
      render json: [Forecast.new(company, teams, time_period.start_date, time_period.end_date, year)]
    elsif current_user.leader?
      render json: [Forecast.new(company, teams, time_period.start_date, time_period.end_date, year)]
    else
      render json: forecast_member
    end
  end

  def detail
    if valid_time_period?
      start_date = time_period.start_date
      end_date = time_period.end_date

      quarters = (start_date.to_date..end_date.to_date).map { |d| 'q' + ((d.month - 1) / 3 + 1).to_s + '-' + d.year.to_s }.uniq
      if user.present?
        if params[:product_id].present?
          data = ProductForecastMember.new(user, product, start_date, end_date, nil, nil)
        else
          data = ForecastMember.new(user, start_date, end_date, nil, nil)
        end
        render json: { forecast: QuarterlyForecastMemberSerializer.new(data), quarters: quarters }
      elsif team.present?
        if params[:product_id].present?
          data = ProductForecastTeam.new(team, product, start_date, end_date, nil, nil)
        else
          data = ForecastTeam.new(team, start_date, end_date, nil, nil)
        end
        render json: { forecast: QuarterlyForecastTeamSerializer.new(data), quarters: quarters }
      else
        if params[:product_id].present?
          data = ProductForecast.new(company, teams, product, start_date, end_date, nil)
        else
          data = Forecast.new(company, teams, start_date, end_date, nil)
        end
        render json: { forecast: QuarterlyForecastSerializer.new(data), quarters: quarters }
      end
    else
      render json: { errors: [ "Time period is not valid" ] }, status: :unprocessable_entity
    end
  end

  def show
    render json: ForecastTeam.new(team, time_period.start_date, time_period.end_date, nil, year)
  end

  protected

  def forecast_member
    if year
      quarters.map do |dates|
        ForecastMember.new(current_user, dates[:start_date], dates[:end_date], dates[:quarter], year)
      end
    else
      if user.present?
        [ForecastMember.new(user, time_period.start_date, time_period.end_date)]
      else
        [ForecastMember.new(current_user, time_period.start_date, time_period.end_date)]
      end

    end
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
    if params[:id] && params[:id] != 'all'
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

end
