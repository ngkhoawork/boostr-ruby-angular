class Api::ClientConnectionsController < ApplicationController
  respond_to :json

  def index
    if client && client.client_type
      if client.client_type.name == "Agency"
        render json: client.agency_connections
      elsif client.client_type.name == "Advertiser"
        render json: client.advertiser_connections
      end
    else
      render json: []
    end
  end

  def create
    new_client_connection = ClientConnection.new(client_connection_params)
    if new_client_connection.save
      render json: new_client_connection, status: :created
    else
      render json: { errors: new_client_connection.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if client_connection.update_attributes(client_connection_params)
      render json: client_connection, status: :accepted
    else
      render json: { errors: client_connection.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    client_connection.destroy
    render nothing: true
  end

  private

  def client_connection_params
    params.require(:client_connection).permit(:agency_id, :advertiser_id, :primary, :active)
  end

  def client
    @client ||= current_user.company.clients.find(params[:client_id])
  end

  def client_connection
    @client_connection ||= ClientConnection.find(params[:id])
  end

end
