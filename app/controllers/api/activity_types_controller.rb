class Api::ActivityTypesController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        render json: activity_types
      }
    end
  end

  def create
    activity_type = company.activity_types.new(activity_params)

    if activity_type.save
      render json: activity_type, status: :created
    else
      render json: { errors: activity_type.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def activity_params
    params.require(:activity_type).permit(:name, :action, :icon, :active, :position)
  end

  def activity_type
    @_activity_type ||= company.activity_types.find(params[:id])
  end

  def activity_types
    current_user.company.activity_types
  end

  def company
    @_company ||= current_user.company
  end
end
