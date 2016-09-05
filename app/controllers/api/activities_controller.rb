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
      contacts.concat process_raw_contact_data if params[:guests]
      @activity.contacts = contacts
      render json: activity, status: :created
    else
      render json: { errors: activity.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if activity.update_attributes(activity_params)
      contacts = company.contacts.where(id: params[:contacts])
      contacts.concat process_raw_contact_data if params[:guests]
      activity.contacts = contacts
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

  def process_raw_contact_data
    addresses = params[:guests].map { |c| c[:address][:email] }
    existing_contact_ids = Address.contacts_by_email(addresses).map(&:addressable_id)
    existing_company_contacts = Contact.where(id: existing_contact_ids, company_id: current_user.company_id)
    new_contacts = []

    if existing_company_contacts.length < params[:guests].length
      existing_emails = existing_company_contacts.map(&:address).map(&:email)
      new_incoming_contacts = params[:guests].reject do |raw_contact|
        existing_emails.include?(raw_contact[:address][:email])
      end

      new_incoming_contacts.each do |new_contact_data|
        contact = current_user.company.contacts.new(
          name: new_contact_data['name'],
          address_attributes: { email: new_contact_data['address']['email'] },
          created_by: current_user.id
        )
        if contact.save
          new_contacts << contact
        end
      end
    end

    existing_company_contacts.where.not(id: params[:contacts]) + new_contacts
  end

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
      current_user.all_activities
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
