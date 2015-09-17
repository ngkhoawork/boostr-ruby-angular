class Api::ForecastsController < ApplicationController
  respond_to :json

  def index
    if current_user.leader?
      teams = current_user.company.teams.roots(true)
      render json: Forecast.new(teams)
    else
      render nothing: true
    end
  end

  def show
    team = current_user.company.teams.find(params[:id])
    render json: ForecastTeam.new(team)
  end

end
