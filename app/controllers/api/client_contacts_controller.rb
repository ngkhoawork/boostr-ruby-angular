class Api::ClientContactsController < ApplicationController
  respond_to :json

  def index
    render json: related_clients_through_contacts
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

  private

  def client_contact_params
    params.require(:client_contact).permit(:client_id, :contact_id)
  end

  def client
    @client ||= current_user.company.clients.find(params[:client_id])
  end

  def client_contact
    @client_member ||= client.client_contacts.find(params[:id])
  end

  def related_clients_through_contacts
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
end
