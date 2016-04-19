class Api::ActivitiesController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        render json: activities
      }
    end
  end

  def create
      @activity = company.activities.new(activity_params)
      activity.user_id = current_user.id
      activity.created_by = current_user.id
      activity.updated_by = current_user.id
      if activity.save
        render json: activity, status: :created
      else
        render json: { errors: activity.errors.messages }, status: :unprocessable_entity
      end
  end

  def update
    if activity.update_attributes(activity_params)
      render json: client, status: :accepted
    else
      render json: { errors: client.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    activity.destroy
    render nothing: true
  end

  private

  def activity_params
    params.require(:activity).permit(:type, :deal_id, :client_id, :contact_id, :user_id, :comment, :happened_at, :activity_type, :timed)
  end

  def activity
    @activity ||= company.activities.find(params[:id])
  end

  def activities
    current_user.all_activities
  end

  def company
    @company ||= current_user.company
  end

  def team
    if current_user.leader?
      company.teams.where(leader: current_user).first!
    else
      current_user.team
    end
  end
end
