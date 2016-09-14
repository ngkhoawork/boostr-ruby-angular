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
    @activity = company.activities.build(activity_params)
    @activity.user_id = current_user.id
    @activity.created_by = current_user.id
    @activity.updated_by = current_user.id
    if @activity.save
      contacts = company.contacts.where(id: params[:contacts])
      contacts.each do |contact|
        @activity.contacts << contact
      end
      render json: activity, status: :created
    else
      render json: { errors: activity.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if activity.update_attributes(activity_params)
      contacts = company.contacts.where(id: params[:contacts])
      activity.contacts = []
      contacts.each do |contact|
        activity.contacts << contact
      end
      render json: activity, status: :accepted
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
    params.require(:activity).permit(
      :type,
      :deal_id,
      :client_id,
      :agency_id,
      :user_id,
      :activity_type_id,
      :activity_type_name,
      :comment,
      :happened_at,
      :activity_type,
      :timed,
      :google_event_id,
      :uuid
    )
  end

  def activity
    @activity ||= company.activities.find(params[:id])
  end

  def activities
    if params[:google_event_id]
      current_user.activities.where(google_event_id: params[:google_event_id])
    else
      if params[:page]
        offset = (params[:page].to_i - 1) * 10
        if params[:filter] == "team"
          team_members = current_user.all_team_members.collect{|member| member.id}
          clients = ClientMember.where("user_id in (?)", team_members).collect{|member| member.client_id}
          company.activities.where("client_id in (?)", clients).order("happened_at desc").limit(10).offset(offset)
        elsif params[:filter] == "client"
          clients = current_user.clients.collect{|member| member.id}
          company.activities.where("client_id in (?)", clients).order("happened_at desc").limit(10).offset(offset)
        else
          current_user.activities.order("happened_at desc").limit(10).offset(offset)
        end


      else
        current_user.all_activities
      end
    end
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
