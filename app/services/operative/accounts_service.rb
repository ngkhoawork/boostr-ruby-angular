class Operative::AccountsService
  def initialize(account, options, deal_id)
    @account = account
    @options = options
    @deal_id = deal_id
  end

  def perform
    send_account
  end

  private

  attr_reader :account, :mapped_object, :options, :deal_id

  def send_account
    account_integration_blank? ? create_account_and_integration_object : update_account
  end

  def mapped_object
    @_mapped_object ||= Operative::Clients::Single.new(account).to_hash
  end

  def v1_api_client
    Operative::V1::Client.new(options)
  end

  def create_account
    v1_api_client.create_account(params: mapped_object, deal_id: deal_id)
  end

  def create_account_and_integration_object
    if external_id_from_response.present?
      account.integrations.create!(external_id: external_id_from_response, external_type: Integration::OPERATIVE)
      response_from_create
    end
  end

  def external_id_from_response
    @_external_id_from_response ||= Operative::XmlParserService.new(response_from_create, element: 'accountId').perform
  end

  def response_from_create
    @_response_from_create ||= create_account
  end

  def update_account
    v1_api_client.update_account(params: mapped_object, id: account_external_id, deal_id: deal_id)
  end

  def account_operative_integration
    @_account_operative_integration ||= account.integrations.operative
  end

  def account_integration_blank?
    account_operative_integration.blank? || account_external_id.blank?
  end

  def account_external_id
    account_operative_integration.external_id
  end
end
