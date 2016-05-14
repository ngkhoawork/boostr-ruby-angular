class Api::StagesController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.stages
  end

  def show
    render json: stage
  end

  def create
    stage = current_user.company.stages.create(stage_params)

    if stage.persisted?
      render json: stage
    else
      render json: { errors: stage.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if stage.update_attributes(stage_params)
      render json: stage
    else
      render json: { errors: stage.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def stage
    @stage ||= current_user.company.stages.find(params[:id])
  end

  def stage_params
    params.require(:stage).permit(:name, :probability, :position, :open, :active, :avg_day, :yellow_threshold, :red_threshold)
  end
end
