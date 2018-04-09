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
    activity_type = company.activity_types.new(activity_params.merge(position: position))

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

  def update_positions
    positions = params[:activity_types_position]
    activity_types = company.activity_types.where(id: positions.keys)

    activity_types.each do |activity_type|
      activity_type.update(position: positions[activity_type.id.to_s])
    end

    render json: activity_types
  end

  private

  def activity_params
    params.require(:activity_type).permit(:name, :action, :icon, :css_class, :active, :position)
  end

  def activity_type
    @_activity_type ||= company.activity_types.find(params[:id])
  end

  def all_activity_types
    company.activity_types.ordered_by_position
  end

  def activity_types
    params[:inactive].present? ? all_activity_types : all_activity_types.active
  end

  def company
    @_company ||= current_user.company
  end

  def position
    activity_types.pluck(:position).max.to_i.next
  end
end
