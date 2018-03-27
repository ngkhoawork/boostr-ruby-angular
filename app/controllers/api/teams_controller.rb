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
        temp_team[:leaders] = current_team.all_leaders
        temp_team[:members_count] = temp_team[:members].count
        all_teams << temp_team
      end
      render json: all_teams
    else
      render json: current_user.company.teams.roots(params[:root_only])
    end

  end

  def all_members
    if params[:team_id] && params[:team_id] == "all"
      members = []
      root_teams.each do |team_item|
        members += team_item.all_members.collect{ |member| {id: member.id, name: member.name }}
      end
      render json: members
    else
      current_team = current_user.company.teams.where(id: params[:team_id]).first
      if current_team.present?
        render json: current_team.all_members.collect{ |member| {id: member.id, name: member.name }}
      else
        render json: { errors: current_team.errors.messages }, status: :not_found
      end
    end

  end

  def members
    if params[:team_id].present?
      current_team = current_user.company.teams.where(id: params[:team_id]).first
      if current_team.present?
        render json: current_team.all_members.collect{ |member| {id: member.id, name: member.name }}
      else
        render json: { errors: current_team.errors.messages }, status: :not_found
      end
    end
  end

  def all_sales_reps
    if !teams.present?
      render json: { error: 'Team Not Found' }, status: :not_found
    else
      reps = teams.map(&:all_sales_reps).flatten
      render json: reps
    end
  end

  def all_account_managers
    if !(teams.present?)
      render json: { error: 'Team Not Found' }, status: :not_found
    else
      reps = teams.map(&:all_account_managers).flatten
      render json: reps
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

  def by_user
    render json: team_by_user.as_json(override: true, only: [:id, :name])
  end

  private

  def teams
    if params[:team_id] && params[:team_id] == 'all'
      @team ||= root_teams
    elsif params[:team_id]
      @team ||= [company.teams.find(params[:team_id])]
    end
  end

  def root_teams
    company.teams.roots(true)
  end

  def team_params
    params.require(:team).permit(
      :name, 
      :parent_id, 
      :leader_id, 
      :member_ids,
      :sales_process_id,
      member_ids: []
    )
  end

  def team
    @team ||= current_user.company.teams.where(id: params[:id]).first
  end

  def company
    @company ||= current_user.company
  end

  def user
    @_user ||= company.users.find(params[:id])
  end

  def team_by_user
    if user.leader?
      user.teams
    else
      [user.team]
    end
  end
end
