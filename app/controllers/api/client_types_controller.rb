class Api::ClientTypesController < ApplicationController
  respond_to :json, :csv

  def index
    client_types = current_user.company.client_types.order(:position)
    render json: client_types
  end

  def create
    @client_type = current_user.company.client_types.create(client_type_params)
    if client_type.persisted?
      render json: client_type, status: :created
    else
      render json: { errors: client_type.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if client_type.update_attributes(client_type_params)
      render json: client_type, status: :accepted
    else
      render json: { errors: client_type.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    client_type.destroy
    render nothing: true
  end

  private

  def client_type_params
    params.require(:client_type).permit(:name, :position)
  end

  def client_type
    @client_type ||= current_user.company.client_types.where(id: params[:id]).first!
  end
end
