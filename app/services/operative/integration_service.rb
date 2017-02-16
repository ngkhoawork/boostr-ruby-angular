class Operative::IntegrationService
  attr_reader :deal, :agency, :advertiser, :agency_mapped_object, :advertiser_mapped_object

  def initialize(deal)
    @deal = deal
    @agency = @deal.agency
    @advertiser = @deal.advertiser
  end

  def perform
    send_accounts
  end

  private

  def send_accounts
    Operative::AccountsService.new(agency).perform
    Operative::AccountsService.new(advertiser).perform
  end
end
