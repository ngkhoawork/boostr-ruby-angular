class Api::ClientsController < ApplicationController
  respond_to :json, :csv

  def index
    clients = current_user.company.clients.order(:name).includes(:address)

    respond_to do |format|
      format.json { render json: clients }
      format.csv { send_data clients.to_csv, filename: "clients-#{Date.today}.csv" }
    end
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

  def update
    if client.update_attributes(client_params)
      render json: client, status: :accepted
    else
      render json: { errors: client.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    client.destroy
    render nothing: true
  end

  private

  def client_params
    params.require(:client).permit(:name, :website, :client_type_id, address_attributes: [ :street1,
    :street2, :city, :state, :zip, :phone, :email])
  end

  def client
    @client ||= current_user.company.clients.where(id: params[:id]).first
  end
end
