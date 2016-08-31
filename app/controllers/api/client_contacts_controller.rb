class Api::ClientContactsController < ApplicationController
  respond_to :json

  def index
    render json: related_clients_through_contacts
  end

  private

  def related_clients_through_contacts
    @client ||= current_user.company.clients.find(params[:client_id])

    related_clients = []
    @client.contacts.each do |contact|
      related_clients.concat contact.clients.opposite_type_id(@client.client_type_id).exclude_ids(related_clients.map(&:id))
    end

    related_clients.as_json.each do |client|
      client['contacts'].delete_if { |contact| !(@client.contacts.ids.include?(contact["id"])) }
    end
  end
end
