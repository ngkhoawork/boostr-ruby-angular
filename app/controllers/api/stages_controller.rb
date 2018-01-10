class Api::StagesController < ApplicationController
  respond_to :json

  def index
    stages = if params[:team_id] && team_stages
      team_stages
    elsif params[:sales_process_id] && sales_process
      sales_process.stages
    elsif params[:current_team]
      current_user.current_team.try(:sales_process).try(:stages) || default_stages
    else
      company.stages
    end
    stages = stages.is_active(params[:active])
                .is_open(params[:open])
    render json: stages, each_serializer: StageSerializer
  end

  def show
    render json: stage, serializer: StageSerializer
  end

  def create
    stage = current_user.company.stages.create(stage_params)

    if stage.persisted?
      render json: stage, serializer: StageSerializer
    else
      render json: { errors: stage.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if stage.update_attributes(stage_params)
      render json: stage, serializer: StageSerializer
    else
      render json: { errors: stage.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def sales_process
    @_sales_process ||= company.sales_processes.find(params[:sales_process_id])
  end

  def team_stages
    if team.present?
      @_stages ||= team.sales_process.try(:stages) 
      @_stages ||= default_stages
    end
  end

  def default_stages
    @_default_stages ||= company.default_sales_process.try(:stages)
  end

  def team
    @_team ||= company.teams.find(params[:team_id])
  end

  def company
    @_company ||= current_user.company
  end

  def stage
    @_stage ||= current_user.company.stages.find(params[:id])
  end

  def stage_params
    params.require(:stage).permit(:name, :probability, :position, :open, :active, :avg_day, :yellow_threshold, :red_threshold, :sales_process_id)
  end
end