class Api::V2::ClientContactsController < ApiController
  respond_to :json

  def index
    render json: client.contacts.order(:name).includes(:address)
  end

  def related_clients
    render json: related_clients_through_contacts
  end

  private

  def client
    @client ||= current_user.company.clients.find(params[:client_id])
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
