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

  def update
    if activity_type.update(activity_params)
      render json: activity_type
    else
      render json: { errors: activity_type.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if activity_type.activities.blank?
      activity_type.destroy

      render nothing: true
    else
      render json: { errors: 'You can\'t delete activity type which is linked to activity' },
             status: :unprocessable_entity
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
    current_user.company.activity_types.ordered_by_position
  end

  def company
    @_company ||= current_user.company
  end
end
