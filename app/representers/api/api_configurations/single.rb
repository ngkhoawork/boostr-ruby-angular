class API::ApiConfigurations::Single < API::Single
  properties :id, :integration_type, :company_id, :switched_on, :trigger_on_deal_percentage, :base_link, :api_email
end