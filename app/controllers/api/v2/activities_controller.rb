class Api::V2::ActivitiesController < ApiController
  def index
    render json: activities.includes(:creator, :client, :deal, :publisher, :contacts_info),
           each_serializer: Api::V2::ActivityListSerializer
  end

  def show
    render json: activity
  end

  def create
    @activity = company.activities.build(activity_params)
    @activity.user_id = current_user.id
    @activity.created_by = current_user.id
    @activity.updated_by = current_user.id

    if @activity.save
      current_user_contact = Contact.by_email(current_user.email, current_user.company_id)

      activity_contacts = []
      activity_contacts += params[:contacts] if params[:contacts]
      activity_contacts += process_raw_contact_data if params[:guests]

      contacts = company.contacts.where(id: activity_contacts).where.not(id: current_user_contact.ids)
      @activity.contacts = contacts
      render json: activity, status: :created
    else
      render json: { errors: activity.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if activity.update_attributes(activity_params)
      current_user_contact = Contact.by_email(current_user.email, current_user.company_id)

      activity_contacts = []
      activity_contacts += params[:contacts] if params[:contacts]
      activity_contacts += process_raw_contact_data if params[:guests]

      contacts = company.contacts.where(id: activity_contacts).where.not(id: current_user_contact.ids)
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

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def limit
    params[:per].present? ? params[:per].to_i : 10
  end

  def activity
    @activity ||= company.activities.find(params[:id])
  end

  def activities
    if params[:contact_id]
      Activity.for_company(company_id).for_contact(params[:contact_id])
    elsif params[:page] && params[:filter] == "client"
      client_activities
    else
      current_user.all_activities
    end
  end

  def client_activities
    if current_user.user_type == EXEC && !(current_user.team.presence) && (!current_user.leader? || current_user.all_team_members.count == 0)
      Activity.for_company(company_id).order("happened_at desc").limit(limit).offset(offset)
    elsif current_user.leader?
      team_member_ids = team.all_members.map(&:id) + team.all_leaders.map(&:id)

      client_ids = ClientMember.where("user_id in (?)", team_member_ids).collect{|member| member.client_id}
      company.activities.where('client_id in (?) OR created_by in (?)', client_ids, team_member_ids).order("happened_at desc").limit(limit).offset(offset)
    else
      client_ids = current_user.clients.collect{|member| member.id}
      company.activities.where('client_id in (?) OR created_by = ?', client_ids, current_user.id).order("happened_at desc").limit(limit).offset(offset)
    end
  end

  def company
    @company ||= current_user.company
  end

  def company_id
    current_user.company_id
  end

  def team
    if current_user.leader?
      company.teams.where(leader: current_user).first!
    else
      current_user.team
    end
  end

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

  def activity_csv_report
    CSV.generate do |csv|
      header = []
      header << "Date"
      header << "Type"
      header << "Comments"
      header << "Advertiser"
      header << "Agency"
      header << "Contacts"
      header << "Deal"
      header << "Creator"
      csv << header

      activities.each do |row|
        line = []
        line << row.happened_at.strftime("%m/%d/%Y")
        line << row.activity_type_name
        line << row.comment
        line << (row.client.nil? ? "" : row.client.name)
        line << (row.agency.nil? ? "" : row.agency.name)
        contacts = ""
        row.contacts.each do |contact|
          contacts += contact.name + "\n"
        end
        line << contacts
        line << (row.deal.nil? ? "" : row.deal.name)
        line << (row.creator.nil? ? "" : row.creator.first_name + " " + row.creator.last_name)
        csv << line
      end
    end
  end

  def filtered_activities
    query_str = "user_id in (?)"
    is_company_activity = false
    member_ids = []
    if params[:member_id] && params[:member_id] != "all"
      member_ids << params[:member_id]
    elsif params[:team_id] && params[:team_id] != "all"
      if team.present?
        member_ids += team.all_members.collect{|member| member.id}
      end
    else
      is_company_activity = true
      query_str = "company_id = #{company.id}"
    end


    if params[:activity_type_id]
      query_str += " and activity_type_id = #{params[:activity_type_id]}"
    end

    if params[:start_date] && params[:end_date]
      start_date = Date.parse(params[:start_date])
      end_date = Date.parse(params[:end_date]).end_of_day
    else
      end_date = Time.now.end_of_day
      start_date = end_date - 30.days
    end
    query_str += " and happened_at >= '#{start_date}' and happened_at <= '#{end_date}'"

    if is_company_activity == true
      data = company.activities.where(query_str)
    else
      data = company.activities.where(query_str, member_ids)
    end

    # puts data
    data
  end

  def root_teams
    company.teams.roots(true)
  end
end
