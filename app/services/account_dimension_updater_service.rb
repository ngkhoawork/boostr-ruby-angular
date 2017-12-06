class AccountDimensionUpdaterService < BaseService

  def perform
    return if client.deleted_at
    update_or_create_dimension if params_changed?
  end

  private

  def params_changed?
    account_dimension.attributes != client_attributes
  end

  def update_or_create_dimension
    account_dimension.update(client_attributes)
  end

  def client_attributes
    { id: client.id,
      name: client.name,
      account_type: global_type_id,
      category_id: client.client_category_id,
      subcategory_id: client.client_subcategory_id,
      holding_company_id: client.holding_company_id,
      client_region_id: client.client_region_id,
      client_segment_id: client.client_segment_id,
      company_id: client.company_id }
  end

  def global_type_id
    return unless client.client_type_id
    return Client::ADVERTISER if client.client_type_id == advertiser_type_id
    Client::AGENCY if client.client_type_id == agency_type_id
  end

  def advertiser_type_id
    account_type_options_id('Advertiser')
  end

  def agency_type_id
    account_type_options_id('Agency')
  end

  def account_type_options_id(option_name)
    client_type_field.options.find_by('options.name = ?', option_name).id
  end

  def client_type_field
    @_field ||= Field.find_by(company_id: client.company_id, name: 'Client Type')
  end

  def account_dimension
    @_account_dimension ||= AccountDimension.find_or_initialize_by(id: client.id)
  end
end