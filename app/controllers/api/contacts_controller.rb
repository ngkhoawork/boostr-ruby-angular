class Api::ContactsController < ApplicationController
  respond_to :json

  def create
    contact = current_user.company.contacts.new(contact_params)
    contact.created_by = current_user.id
    if contact.save
      render json: contact, status: :created
    else
      render json: { errors: contact.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :position, :client_id, address_attributes: [:street1,
    :street2, :city, :state, :zip, :phone, :email])
  end

  def contact
    @contact ||= current_user.company.contacts.where(id: params[:id]).first
  end
end