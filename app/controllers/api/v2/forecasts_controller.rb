class Api::V2::ForecastsController < ApiController
  respond_to :json

  def index
    if current_user.leader?
      render json: [Forecast.new(company, teams, time_period.start_date, time_period.end_date, year)]
    else
      render json: forecast_member
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
      [ForecastMember.new(current_user, time_period.start_date, time_period.end_date)]
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

  def teams
    return @teams if defined?(@teams)
    @teams = company.teams.roots(true)
  end

  def team
    return @team if defined?(@team)
    @team = company.teams.find(params[:id])
  end

  def company
    return @company if defined?(@company)
    @company = current_user.company
  end
end
