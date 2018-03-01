class Api::StagesController < ApplicationController
  respond_to :json

  def index
    render json: filtered_stages, each_serializer: StageSerializer
  end

  def show
    render json: stage, serializer: StageSerializer
  end

  def create
    stage = current_user.company.stages.create(stage_params)

    if stage.persisted?
      render json: stage, status: :created, serializer: StageSerializer
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

  def company
    @_company ||= current_user.company
  end

  def stage
    @_stage ||= current_user.company.stages.find(params[:id])
  end

  def filtered_stages
    StagesQuery.new(filter_params).perform
  end

  def stage_params
    params.require(:stage).permit(:name, :probability, :position, :open, :active, :avg_day, :yellow_threshold, :red_threshold, :sales_process_id)
  end

  def filter_params
    params.permit(:team_id, :sales_process_id, :current_team, :active, :open)
          .merge(current_user: current_user, company_id: current_user.company_id)
  end
end