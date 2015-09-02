class Api::StagesController < ApplicationController
  respond_to :json

  def index
    render json: current_user.company.stages.order(:position)
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
    params.require(:stage).permit(:name, :probability, :position, :open, :active)
  end
end
