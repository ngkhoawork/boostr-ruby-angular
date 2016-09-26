class Api::DealContactsController < ApplicationController
  respond_to :json

  def index
    render json: client_contacts
  end

  def create
    deal_contact = deal.deal_contacts.build(deal_contact_params)
    if deal_contact.save
      render json: deal_contact, status: :created
    else
      render json: { errors: deal_contact.errors.messages }, status: :unprocessable_entity
    end
  end

  private

  def deal_contact_params
    params.require(:deal_contact).permit(:contact_id)
  end

  def client_contacts
    deal_clients_ids = []
    deal_clients_ids << deal.agency.id if deal.agency
    deal_clients_ids << deal.advertiser.id if deal.advertiser

    Contact.joins("INNER JOIN client_contacts ON contacts.id=client_contacts.contact_id").where("client_contacts.client_id in (:q)", {q: deal_clients_ids}).by_name(params[:name]).order(:name).limit(10).distinct
  end

  def deal
    @deal ||= current_user.company.deals.find(params[:deal_id])
  end
end
