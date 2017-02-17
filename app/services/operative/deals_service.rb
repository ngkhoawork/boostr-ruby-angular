class Operative::DealsService
  def initialize(deal)
    @deal = deal
  end

  def perform
    send_deal
  end

  private

  attr_reader :deal, :mapped_object

  def send_deal
    deal_integration_blank? ? create_deal_and_integration_object : update_deal
  end

  def mapped_object
    @_mapped_object ||= Operative::Deals::Single.new(deal).to_xml(create: create_deal?)
  end

  def v2_api_client
    Operative::V2::Client.new
  end

  def create_deal
    v2_api_client.create_order(params: mapped_object)
  end

  def create_deal_and_integration_object
    deal.integrations.create!(external_id: external_id_from_response, external_type: Integration::OPERATIVE)
  end

  def external_id_from_response
    Operative::XmlParserService.new(create_deal, element: 'id', deal: true).perform
  end

  def update_deal
    v2_api_client.update_order(params: mapped_object, id: deal_external_id)
  end

  def deal_operative_integration
    @_deal_operative_integration ||= deal.integrations.operative
  end

  def deal_integration_blank?
    deal_operative_integration.blank?
  end

  def deal_external_id
    deal_operative_integration.external_id
  end

  def create_deal?
    deal_integration_blank?
  end
end
