class API::ApiConfigurations::Single < API::Single
  properties :id,
             :integration_type,
             :integration_provider,
             :company_id,
             :switched_on,
             :trigger_on_deal_percentage,
             :base_link,
             :api_email,
             :network_code,
             :recurring

  property :cumulative_dfp_report_query, exec_context: :decorator
  property :monthly_dfp_report_query, exec_context: :decorator
  property :cpm_budget_adjustment, exec_context: :decorator
  property :json_api_key, exec_context: :decorator
  property :asana_connect_details, exec_context: :decorator
  property :datafeed_configuration_details, exec_context: :decorator
  property :google_sheets_details, exec_context: :decorator
  property :hoopla_details, exec_context: :decorator
  property :job_status, exec_context: :decorator
  property :can_be_scheduled, exec_context: :decorator

  private

  def json_api_key
    represented.json_api_key if represented.integration_type == 'DfpApiConfiguration'
  end

  def cpm_budget_adjustment
    represented.cpm_budget_adjustment if represented.integration_type == 'DfpApiConfiguration'
  end

  def cumulative_dfp_report_query
    represented.dfp_report_queries.cumulative.last if represented.integration_type == 'DfpApiConfiguration'
  end

  def monthly_dfp_report_query
    represented.dfp_report_queries.monthly.last if represented.integration_type == 'DfpApiConfiguration'
  end

  def asana_connect_details
    represented.asana_connect_details if represented.integration_type == 'AsanaConnectConfiguration'
  end

  def datafeed_configuration_details
    represented.datafeed_configuration_details if represented.integration_type == 'OperativeDatafeedConfiguration'
  end

  def google_sheets_details
    represented.google_sheets_details if represented.integration_type == 'GoogleSheetsConfiguration'
  end

  def hoopla_details
    represented.hoopla_details if represented.integration_type == 'HooplaConfiguration'
  end

  def job_status
    represented.job_status if represented.integration_type == 'OperativeDatafeedConfiguration'
  end

  def can_be_scheduled
    represented.can_be_scheduled? if represented.integration_type == 'OperativeDatafeedConfiguration'
  end
end
