class Api::ClientsController < ApplicationController
  respond_to :json

  def index
    clients = current_user.company.clients.order(:name).includes(:address)
    render json: clients
  end

  def create
    client = current_user.company.clients.new(client_params)
    client.created_by = current_user.id
    if client.save
      render json: client, status: :created
    else
      render json: { errors: client.errors.messages }, status: :unprocessable_entity
    end
  end


  private

  def client_params
    params.require(:client).permit(:name, :website, address_attributes: [ :street1,
    :street2, :city, :state, :zip, :phone, :email])
  end
end
