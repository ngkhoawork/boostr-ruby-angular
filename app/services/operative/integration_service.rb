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
    Operative::AccountsService.new(agency, auth_details, deal.id).perform if agency
    Operative::AccountsService.new(advertiser, auth_details, deal.id).perform
  end

  def send_contact
    Operative::ContactsService.new(contact, account_name, auth_details, deal.id).perform if contact
  end

  def send_deal
    Operative::DealsService.new(deal, advertiser?, auth_details).perform
  end

  def auth_details
    @_api_config ||= Operative::AuthDetailsService.new(api_configuration).perform
  end

  def api_configuration
    deal.company.operative_api_config
  end

  def account_name
    determine_contact_relation_to_client.name
  end

  def determine_contact_relation_to_client
    advertiser? ? advertiser : agency
  end

  def advertiser?
    advertiser.contacts.include?(contact)
  end
end
