class Operative::IntegrationService
  def initialize(deal_id)
    @deal = Deal.find(deal_id)
    @agency = @deal.agency
    @advertiser = @deal.advertiser
    @contact = @deal.contacts.order(:created_at).first
  end

  def perform
    send_accounts
    send_contact
    send_deal
  end

  private

  attr_reader :deal, :agency, :advertiser, :contact

  def send_accounts
    Operative::AccountsService.new(agency).perform if agency
    Operative::AccountsService.new(advertiser).perform
  end

  def send_contact
    Operative::ContactsService.new(contact, advertiser.name).perform if contact
  end

  def send_deal
    Operative::DealsService.new(deal).perform
  end
end
