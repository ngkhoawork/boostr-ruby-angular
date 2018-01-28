class Operative::DealsService
  def initialize(deal, advertiser, options)
    @deal = deal
    @advertiser = advertiser
    @options = options
  end

  def perform
    send_deal
  end

  private

  attr_reader :deal, :mapped_object, :options, :advertiser

  def send_deal
    deal_integration_blank? ? create_deal_and_integration_object : update_deal
  end

  def mapped_object
    @_mapped_object ||= Operative::Deals::Single.new(deal).to_xml(
      create: create_deal?,
      advertiser: advertiser,
      agency: agency?,
      closed_lost: closed_lost?,
      contact: contact?,
      enable_operative_extra_fields: deal.company.enable_operative_extra_fields,
      buzzfeed: buzzfeed?
    )
  end

  def v2_api_client
    Operative::V2::Client.new(options)
  end

  def create_deal
    v2_api_client.create_order(params: mapped_object, deal_id: deal.id)
  end

  def create_deal_and_integration_object
    if external_id_from_response.present?
      deal.integrations.create!(external_id: external_id_from_response, external_type: Integration::OPERATIVE)
      response_from_create
    end
  end

  def external_id_from_response
    @_external_id_from_response ||= Operative::XmlParserService.new(response_from_create, element: 'id', deal: true).perform
  end

  def response_from_create
    @_response_from_create ||= create_deal
  end

  def update_deal
    v2_api_client.update_order(params: mapped_object, id: deal_external_id, deal_id: deal.id)
  end

  def deal_operative_integration
    @_deal_operative_integration ||= deal.integrations.operative
  end

  def deal_integration_blank?
    deal_operative_integration.blank? || deal_external_id.blank?
  end

  def deal_external_id
    deal_operative_integration.external_id
  end

  def create_deal?
    deal_integration_blank?
  end

  def agency?
    deal.agency.present?
  end

  def closed_lost?
    deal.closed_lost?
  end

  def contact?
    deal.ordered_by_created_at_billing_contacts.any?
  end

  def buzzfeed?
    deal.company.id.eql?(44)
  end
end
