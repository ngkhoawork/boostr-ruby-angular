class Api::ContactsController < ApplicationController
  respond_to :json

  def index
    if params[:unassigned] == "yes"
      contacts = current_user.company.contacts.unassigned(current_user.id)
    elsif params[:name].present?
      contacts = suggest_contacts
    elsif params[:contact_name].present?
      contacts = suggest_contacts(true)
    elsif params[:activity].present?
      contacts = activity_contacts
    else
      contacts = current_user.company.contacts
        .order(:name)
        .includes(:address)
    end

    limit = 500
    if params[:per].present?
      limit = params[:per].to_i
    end
    offset = 0
    if params[:page].present?
      offset = (params[:page].to_i - 1) * limit
    end
    response.headers['X-Total-Count'] = contacts.count.to_s
    contacts = contacts.limit(limit).offset(offset)

    render json: contacts
  end

  def create
    if params[:file].present?
      # csv_file = IO.read(params[:file].tempfile.path)
      csv_file = File.open(params[:file].tempfile.path, "r:ISO-8859-1")
      contacts = Contact.import(csv_file, current_user)
      render json: contacts
    else
      contact = current_user.company.contacts.new(contact_params)
      contact.created_by = current_user.id
      if contact.save
        render json: contact, status: :created
      else
        render json: { errors: contact.errors.messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    if contact.update_attributes(contact_params)
      contact.update_primary_client if params[:contact][:set_primary_client]
      render json: contact.as_json(include: {clients: {}}), status: :accepted
    else
      render json: { errors: contact.errors.messages }, status: :unprocessable_entity
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
      :client_id,
      address_attributes: [
        :id,
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

  def suggest_contacts(contacts_only = false)
    return @search_contacts if defined?(@search_contacts)

    if contacts_only
      @search_contacts = current_user.company.contacts.where('contacts.name ilike ?', "%#{params[:contact_name]}%").limit(10)
    else
      @search_contacts = current_user.company.contacts.joins("LEFT JOIN clients ON clients.id = contacts.client_id").where('contacts.name ilike ? OR clients.name ilike ?', "%#{params[:name]}%", "%#{params[:name]}%").limit(10)
    end
  end

  def activity_contacts
    return @activity_contacts if defined?(@activity_contacts)

    @activity_contacts = current_user.company.contacts.where.not(activity_updated_at: nil).order(activity_updated_at: :desc).limit(10)
  end
end
