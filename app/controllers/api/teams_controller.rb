class Api::TeamsController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.teams.roots
  end

  def create
    team = current_user.company.teams.new(team_params)
    if team.save
      render json: team, status: :created
    else
      render json: { errors: team.errors.messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: team
  end

  private

  def team_params
    params.require(:team).permit(:name, :parent_id)
  end

  def team
    @team ||= current_user.company.teams.where(id: params[:id]).first
  end
end
