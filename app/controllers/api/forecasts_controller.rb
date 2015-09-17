class Api::ForecastsController < ApplicationController
  respond_to :json

  def index
    if current_user.leader?
      render json: Forecast.new(teams, time_period)
    else
      render nothing: true
    end
  end

  def show
    render json: ForecastTeam.new(team, time_period)
  end

  protected

  def time_period
    return @time_period if defined?(@time_period)
    @time_period = current_user.company.time_periods.find(params[:time_period_id])
  end

  def teams
    return @teams if defined?(@teams)
    @teams = current_user.company.teams.roots(true)
  end

  def team
    return @team if defined?(@team)
    @team = current_user.company.teams.find(params[:id])
  end
end
