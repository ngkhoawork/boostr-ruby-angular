class Api::ClientsController < ApplicationController
  respond_to :json, :csv

  def index
    ordered_clients = clients.order(:name).includes(:address).distinct

    respond_to do |format|
      format.json { render json: ordered_clients }
      format.csv { send_data ordered_clients.to_csv, filename: "clients-#{Date.today}.csv" }
    end
  end

  def show
    render json: client
  end

  def create
    if params[:file].present?
      csv_file = IO.read(params[:file].tempfile.path)
      clients = Client.import(csv_file, current_user)
      render json: clients
    else
      client = company.clients.new(client_params)
      client.created_by = current_user.id
      if client.save
        render json: client, status: :created
      else
        render json: { errors: client.errors.messages }, status: :unprocessable_entity
      end
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
    params.require(:client).permit(:name, :website, :client_type_id, { address_attributes: [ :street1,
    :street2, :city, :state, :zip, :phone, :email], values_attributes: [:id, :field_id, :option_id, :value] })
  end

  def client
    @client ||= company.clients.where(id: params[:id]).first!
  end

  def clients
    if params[:filter] == 'company' && current_user.leader?
      company.clients
    elsif params[:filter] == 'team' && team.present?
      team.clients
    elsif params[:filter] == 'all'
      # TODO eventually we may want to limit this... it is only used in the new deal dropdown
      company.clients
    else
      current_user.clients
    end
  end

  def company
    @company ||= current_user.company
  end

  def team
    if current_user.leader?
      company.teams.where(leader: current_user).first!
    else
      current_user.team
    end
  end
end
