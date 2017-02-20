class Operative::ContactsService
  def initialize(contact, advertiser_name, options)
    @contact = contact
    @advertiser_name = advertiser_name
    @options = options
  end

  def perform
    send_contact
  end

  attr_reader :contact, :advertiser_name, :mapped_object, :options

  private

  def send_contact
    contact_integration_blank? ? create_contact_and_integration_object : update_contact
  end

  def create_contact
    v1_api_client.create_contact(params: mapped_object)
  end

  def create_contact_and_integration_object
    contact.integrations.create!(external_id: external_id_from_response, external_type: Integration::OPERATIVE)
  end

  def external_id_from_response
    Operative::XmlParserService.new(create_contact, element: 'contactId').perform
  end

  def update_contact
    v1_api_client.update_contact(params: mapped_object, id: contact_external_id)
  end

  def v1_api_client
    Operative::V1::Client.new(options)
  end

  def mapped_object
    mapped_object = Operative::Contacts::Single.new(contact).to_hash
    mapped_object['account'] = advertiser_name
    mapped_object
  end

  def contact_operative_integration
    @_contact_operative_integration ||= contact.integrations.operative
  end

  def contact_integration_blank?
    contact_operative_integration.blank? || contact_external_id.blank?
  end

  def contact_external_id
    contact_operative_integration.external_id
  end
end
