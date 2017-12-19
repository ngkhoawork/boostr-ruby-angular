class Api::PublisherContactsController < ApplicationController
  respond_to :json

  def add
    if contact.update(publisher: publisher)
      render json: contact
    else
      render json: { errors: contact.errors.messages }, status: :unprocessable_entity
    end
  end

  def destroy
    contact.update(publisher_id: nil)

    render nothing: true
  end

  private

  def publisher
    company.publishers.find(params[:publisher_id])
  end

  def contact
    company.contacts.find(params[:id])
  end

  def company
    @_company ||= current_user.company
  end
end
