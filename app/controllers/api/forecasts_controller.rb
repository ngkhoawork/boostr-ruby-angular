class Api::ForecastsController < ApplicationController
  respond_to :json

  def index
    if current_user.leader?
      render json: Forecast.new(company, teams, time_period)
    else
      render json: ForecastMember.new(current_user, time_period)
    end
  end

  def show
    render json: ForecastTeam.new(team, time_period)
  end

  protected

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
