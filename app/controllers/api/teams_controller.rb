class Api::TeamsController < ApplicationController
  respond_to :json

  def index
    if params[:all_teams]
      parent_teams = current_user.company.teams.where("parent_id is null")
      all_teams = []
      parent_teams.each do |current_team|
        temp_team = current_team.as_json
        temp_team[:children] = current_team.all_children
        temp_team[:members] = current_team.all_members
        temp_team[:members_count] = temp_team[:members].count
        all_teams << temp_team
      end
      render json: all_teams
    else
      render json: current_user.company.teams.roots(params[:root_only])
    end

  end

  def all_members
    current_team =current_user.company.teams.where(id: params[:team_id]).first
    if current_team.present?
      render json: current_team.all_members
    else
      render json: { errors: current_team.errors.messages }, status: :not_found
    end
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

  def update
    if team.update_attributes(team_params)
      render json: team
    else
      render json: { errors: team.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    team.destroy
    render nothing: true
  end

  private

  def team_params
    params.require(:team).permit(:name, :parent_id, :leader_id, :member_ids, member_ids: [])
  end

  def team
    @team ||= current_user.company.teams.where(id: params[:id]).first
  end
end
