class Api::ActivitiesController < ApplicationController
  respond_to :json, :csv

  def index
    respond_to do |format|
      format.json {
        render json: activities.preload(:activity_type, :assets, :agency, :client, :creator, :publisher, deal: [:stage, :advertiser], contacts: [:address])
      }
      format.csv {
        send_data activity_csv_report, filename: "activity-detail-reports-#{Date.today}.csv"
      }
    end
  end

  def create
    if params[:file].present?
      CsvImportWorker.perform_async(
        params[:file][:s3_file_path],
        'Activity',
        current_user.id,
        params[:file][:original_filename]
      )

      render json: {
        message: "Your file is being processed. Please check status at Import Status tab in a few minutes (depending on the file size)"
      }, status: :ok
    else
      @activity = company.activities.build(activity_params)
      @activity.user_id = current_user.id
      @activity.created_by = current_user.id
      @activity.updated_by = current_user.id

      if @activity.save
        @activity.contacts = add_contacts_to_activity
        @activity.contacts.less_than(@activity.happened_at).update_all(activity_updated_at: @activity.happened_at)

        render json: activity, status: :created
      else
        render json: { errors: activity.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    if activity.update_attributes(activity_params)
      activity.contacts = add_contacts_to_activity
      update_all_activity_updated_at

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

    existing_company_contacts.ids + new_contacts.map(&:id)
  end

  def activity_params
    params.require(:activity).permit(
      :type,
      :deal_id,
      :client_id,
      :agency_id,
      :publisher_id,
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

  def activity_csv_report
    Csv::ActivityDetailService.new(activities).perform
  end

  def activities
    if params[:google_event_id]
      current_user.activities.where(google_event_id: params[:google_event_id])
    elsif params[:contact_id]
      contact = Contact.find(params[:contact_id])
      if contact.present?
        contact.activities
      else
        []
      end
    elsif params[:deal_id]
      Activity.for_company(current_user.company_id).for_deal(params[:deal_id]).order(happened_at: :desc)
    else
      if params[:filter] == "detail"
        filtered_activities
      elsif params[:team_id]
        team.all_activities
      elsif params[:page] && params[:filter] == "client"
        client_filtered_activities
      else
        current_user.all_activities
      end
    end
  end

  def company
    @company ||= current_user.company
  end

  def filtered_activities
    options = {
      company_id: company.id,
      activity_type_id: params[:activity_type_id],
      start_date: parsed_filter_dates[:start_date],
      end_date: parsed_filter_dates[:end_date]
    }

    if params[:member_id] && params[:member_id] != "all"
      options.merge!(member_id: params[:member_id])
    elsif params[:team_id] && params[:team_id] != "all"
      options.merge!(team_id: params[:team_id])
    end

    ActivitiesQuery.new(options).perform
  end

  def client_filtered_activities
    if current_user.user_type == EXEC && !(current_user.team.presence) && (!current_user.leader? || current_user.all_team_members.count == 0)
      result = company.activities
    elsif current_user.leader?
      team_member_ids = team.all_members.map(&:id) + team.all_leaders.map(&:id)

      client_ids = ClientMember.where("user_id in (?)", team_member_ids).collect{|member| member.client_id}
      result = company.activities.where('client_id in (?) OR created_by in (?)', client_ids, team_member_ids)
    else
      client_ids = current_user.clients.collect{|member| member.id}
      result = company.activities.where('client_id in (?) OR created_by = ?', client_ids, current_user.id)
    end

    result.for_time_period(params[:start_date], params[:end_date]).order("happened_at #{sort_direction_filter}").limit(10).offset(offset)
  end

  def sort_direction_filter
    case params[:order]
    when 'asc'
      'asc'
    else
      'desc'
    end
  end

  def offset
    (params[:page].to_i - 1) * 10
  end

  def root_teams
    company.teams.roots(true)
  end

  def team
    if params[:team_id]
      company.teams.find(params[:team_id])
    elsif current_user.leader?
      company.teams.where(leader: current_user).first!
    else
      current_user.team
    end
  end

  def add_contacts_to_activity
    current_user_contact = Contact.by_email(current_user.email, current_user.company_id)

    activity_contacts = []
    activity_contacts += params[:contacts] if params[:contacts]
    activity_contacts += process_raw_contact_data if params[:guests]

    company.contacts.where(id: activity_contacts).where.not(id: current_user_contact.ids)
  end

  def update_all_activity_updated_at
    if activity.contacts.greater_than_happened_at(activity_happened_at).any?
      update_contact_activity_updated_at_field
    else
      activity.contacts.less_than(activity_happened_at).update_all(activity_updated_at: activity_happened_at)
    end
  end

  def update_contact_activity_updated_at_field
    activity.contacts.less_than_happened_at(activity_happened_at).each do |contact|
      contact.update(activity_updated_at: contact.latest_happened_activity.first.happened_at)
    end
  end

  def activity_happened_at
    @_activity_happened_at ||= activity.happened_at
  end

  def parsed_filter_dates
    @parsed_filter_dates ||=
      if params[:start_date] && params[:end_date]
        { start_date: Date.parse(params[:start_date]), end_date: Date.parse(params[:end_date]).end_of_day }
      else
        { start_date: Time.now.end_of_day - 30.days, end_date: Time.now.end_of_day }
      end
  end
end
