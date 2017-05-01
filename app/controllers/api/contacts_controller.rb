class Api::ContactsController < ApplicationController
  respond_to :json

  def index
    if params[:unassigned] == "yes"
      results = unassigned_contacts
    elsif params[:name].present?
      results = suggest_contacts
    elsif params[:contact_name].present?
      results = suggest_contacts(true)
    elsif params[:activity].present?
      results = activity_contacts
    else
      results = contacts
    end

    results = apply_search_criteria(results)

    response.headers['X-Total-Count'] = results.total_count
    render json: results.includes(:primary_client).preload(:values, :address, :workplaces)
      .limit(limit)
      .offset(offset), each_serializer: ContactSerializer,
                       contact_options: company_job_level_options,
                       advertiser: Client.advertiser_type_id(current_user.company),
                       agency: Client.agency_type_id(current_user.company)
  end

  def show
    render json: contact, serializer: Api::ContactDetailSerializer,
                          contact_options: company_job_level_options,
                          advertiser: Client.advertiser_type_id(current_user.company),
                          agency: Client.agency_type_id(current_user.company)
  end

  def create
    if params[:file].present?
      # csv_file = IO.read(params[:file].tempfile.path)
      csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
      contacts = Contact.import(csv_file, current_user)
      render json: contacts
    else
      if contact_params[:client_id].present?
        contact = current_user.company.contacts.new(contact_params)
        contact.created_by = current_user.id
        if contact.save
          render json: contact, status: :created
        else
          render json: { errors: contact.errors.messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: { "primary account": ["can't be blank"] } }, status: :unprocessable_entity
      end

    end
  end

  def update
    if contact_params[:client_id].present? || params[:unassign] == true
      if contact.update_attributes(contact_params)
        contact.update_primary_client if params[:contact][:set_primary_client]
        render json: contact, serializer: ContactUpdateSerializer, status: :accepted
      else
        render json: { errors: contact.errors.messages }, status: :unprocessable_entity
      end
    else
      render json: { errors: { "primary account": ["can't be blank"] } }, status: :unprocessable_entity
    end

  end

  def destroy
    contact.destroy
    render nothing: true
  end

  def metadata
    render json: Contact.metadata(current_user.company_id)
  end

  def related_clients
    render json: contact.workplaces.by_type_id(Client.advertiser_type_id(current_user.company)).as_json(
      override: true,
      only: [:id, :name],
      include: {
        address: {}
      }
    )
  end

  def advertisers
    render json: current_user.company
                             .contacts
                             .with_advertisers_by_name(params[:name])
                             .limit(limit)
                             .as_json(ovveride: true, only: [:id, :name])
  end

  def assign_account
    client_contact = contact.client_contacts.new(client_id: params[:client_id], primary: false)

    if client_contact.save
      render nothing: true
    else
      render json: { errors: client_contact.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(
      :name,
      :position,
      :note,
      :client_id,
      address_attributes: [
        :id,
        :country,
        :street1,
        :street2,
        :city,
        :state,
        :zip,
        :phone,
        :mobile,
        :email
      ],
      contact_cf_attributes: [
        :id,
        :company_id,
        :deal_id,
        :currency1,
        :currency2,
        :currency3,
        :currency4,
        :currency5,
        :currency6,
        :currency7,
        :currency_code1,
        :currency_code2,
        :currency_code3,
        :currency_code4,
        :currency_code5,
        :currency_code6,
        :currency_code7,
        :text1,
        :text2,
        :text3,
        :text4,
        :text5,
        :note1,
        :note2,
        :datetime1,
        :datetime2,
        :datetime3,
        :datetime4,
        :datetime5,
        :datetime6,
        :datetime7,
        :number1,
        :number2,
        :number3,
        :number4,
        :number5,
        :number6,
        :number7,
        :integer1,
        :integer2,
        :integer3,
        :integer4,
        :integer5,
        :integer6,
        :integer7,
        :boolean1,
        :boolean2,
        :boolean3,
        :percentage1,
        :percentage2,
        :percentage3,
        :percentage4,
        :percentage5,
        :dropdown1,
        :dropdown2,
        :dropdown3,
        :dropdown4,
        :dropdown5,
        :dropdown6,
        :dropdown7,
        :number_4_dec1,
        :number_4_dec2,
        :number_4_dec3,
        :number_4_dec4,
        :number_4_dec5,
        :number_4_dec6,
        :number_4_dec7
      ]
    )
  end

  def contact
    @contact ||= current_user.company.contacts.find(params[:id])
  end

  def contacts
    if params[:filter] == 'my_contacts'
      Contact.by_client_ids(current_user.clients.ids)
    elsif params[:filter] == 'team' && team
      Contact.by_client_ids(team.clients.ids)
    else
      current_user.company.contacts.order(:name)
    end
  end

  def apply_search_criteria(rel)
    rel
      .by_primary_client_name(primary_client_criteria)
      .by_city(city_criteria)
      .by_job_level(job_level_criteria)
      .by_country(country_criteria)
      .by_last_touch(params[:start_date], params[:end_date])
  end

  def limit
    params[:per].present? ? params[:per].to_i : 20
  end

  def offset
    params[:page].present? ? (params[:page].to_i - 1) * limit : 0
  end

  def team
    if current_user.leader?
      current_user.company.teams.where(leader: current_user).first!
    else
      current_user.team
    end
  end

  def unassigned_contacts
    current_user.company.contacts.unassigned(current_user.id).limit(limit)
  end

  def suggest_contacts(contacts_only = false)
    return @search_contacts if defined?(@search_contacts)

    if contacts_only
      @search_contacts = current_user.company.contacts.where('contacts.name ilike ?', "%#{params[:contact_name]}%").limit(limit).offset(offset)
    else
      @search_contacts = current_user.company.contacts.joins("LEFT JOIN clients ON clients.id = contacts.client_id").where('contacts.name ilike ? OR clients.name ilike ?', "%#{params[:name]}%", "%#{params[:name]}%").limit(limit).offset(offset)
    end
  end

  def activity_contacts
    @_activity_contacts ||= current_user.company.contacts.where.not(activity_updated_at: nil).order(activity_updated_at: :desc).limit(10)
  end

  def primary_client_criteria
    params[:workplace]
  end

  def city_criteria
    params[:city]
  end

  def job_level_criteria
    params[:job_level]
  end

  def country_criteria
    params[:country]
  end

  def company_job_level_options
    current_user.company.fields.find_by(subject_type: 'Contact', name: 'Job Level').options.select(:id, :field_id, :name)
  end
end
