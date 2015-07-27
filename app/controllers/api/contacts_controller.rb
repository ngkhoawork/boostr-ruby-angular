class Api::ContactsController < ApplicationController
  respond_to :json

  def index
    contacts = current_user.company.contacts
      .for_client(params[:client_id])
      .order(:name)
      .includes(:address)
    render json: contacts
  end

  def create
    contact = current_user.company.contacts.new(contact_params)
    contact.created_by = current_user.id
    if contact.save
      render json: contact, status: :created
    else
      render json: { errors: contact.errors.messages }, status: :unprocessable_entity
    end
  end

  def update
    if contact.update_attributes(contact_params)
      render json: contact, status: :accepted
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
    params.require(:contact).permit(:name, :position, :client_id, address_attributes: [:street1,
    :street2, :city, :state, :zip, :phone, :mobile, :email])
  end

  def contact
    @contact ||= current_user.company.contacts.where(id: params[:id]).first
  end
end
