class Api::V1::ContactsController < ApiController
  respond_to :json

  def index
    if params[:unassigned] == "yes"
      results = current_user.company.contacts.unassigned(current_user.id)
    elsif params[:name].present?
      results = suggest_contacts
    elsif params[:contact_name].present?
      results = suggest_contacts(true)
    elsif params[:activity].present?
      results = activity_contacts
    else
      results = contacts
    end
    response.headers['X-Total-Count'] = results.total_count
    render json: results.limit(limit).offset(offset)
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
        render json: contact, serializer: Api::V1::ContactUpdateSerializer, status: :accepted
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
      ]
    )
  end

  def contact
    @contact ||= current_user.company.contacts.where(id: params[:id]).first
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

  def suggest_contacts(contacts_only = false)
    return @search_contacts if defined?(@search_contacts)

    if contacts_only
      @search_contacts = current_user.company.contacts.where('contacts.name ilike ?', "%#{params[:contact_name]}%").limit(limit).offset(offset)
    else
      @search_contacts = current_user.company.contacts.joins("LEFT JOIN clients ON clients.id = contacts.client_id").where('contacts.name ilike ? OR clients.name ilike ?', "%#{params[:name]}%", "%#{params[:name]}%").limit(limit).offset(offset)
    end
  end

  def activity_contacts
    return @activity_contacts if defined?(@activity_contacts)

    @activity_contacts = current_user.company.contacts.where.not(activity_updated_at: nil).order(activity_updated_at: :desc).limit(10)
  end
end
