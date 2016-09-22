class Api::DealContactsController < ApplicationController
  respond_to :json

  def index
    render json: client_contacts
  end

  private

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
