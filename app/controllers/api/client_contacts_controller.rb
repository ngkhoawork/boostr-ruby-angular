class Api::ClientContactsController < ApplicationController
  include CleanPagination
  respond_to :json

  def index
    if params[:primary]
      client_contacts = client.primary_client_contacts.includes(:contact).order('contacts.name')
    else
      client_contacts = client.client_contacts.includes(:contact).order('contacts.name')
    end
    max_per_page = 100
    paginate client_contacts.count, max_per_page do |limit, offset|
      render json: client_contacts
                    .preload(contact: [:address, :contact_cf, values: [:option, :field]])
                    .limit(limit)
                    .offset(offset),
                    each_serializer: ClientContacts::ClientContactsForClientSerializer,
                                     contact_options: company_job_level_options
    end
  end

  def create
    client_contact = client.client_contacts.build(client_contact_params)
    if client_contact.save
      render json: client_contact, status: :created
    else
      render json: { errors: client_contact.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if client_contact.update_attributes(client_contact_params)
      render json: client_contact, status: :accepted
    else
      render json: { errors: client_contact.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    client_contact.destroy
    render json: true
  end

  def related_clients
    render json: related_clients_through_contacts
  end

  private

  def client
    @client ||= current_user.company.clients.find(params[:client_id])
  end

  def client_contact_params
    params.require(:client_contact).permit(:contact_id, :primary, :is_active)
  end

  def client_contact
    @client_contact ||= client.client_contacts.find(params[:id])
  end

  def related_clients_through_contacts
    #TODO rework this part
    client = current_user.company.clients.find(params[:client_id])
    client_contact_ids = client.contacts.ids
    result = Client.by_contact_ids(client_contact_ids).opposite_type_id(client.client_type_id).includes(:address, contacts: { address: {} })

    result.as_json(
      override: true,
      only: [:id, :name ],
      include: {
        contacts: {
          only: [:id, :name, :position],
          include: :address
        },
      }).each do |client|
        client['contacts'].delete_if { |contact| !(client_contact_ids.include?(contact["id"])) }
    end
  end

  def company_job_level_options
    current_user.company.fields.find_by(subject_type: 'Contact', name: 'Job Level').options.select(:id, :field_id, :name)
  end
end
