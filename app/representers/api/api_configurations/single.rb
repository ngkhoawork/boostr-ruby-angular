class API::ApiConfigurations::Single < API::Single
  properties :id,
             :integration_type,
             :integration_provider,
             :company_id,
             :switched_on,
             :trigger_on_deal_percentage,
             :base_link,
             :api_email,
             :network_code

  property :cumulative_dfp_report_query, exec_context: :decorator
  property :monthly_dfp_report_query, exec_context: :decorator
  property :cpm_budget_adjustment, exec_context: :decorator
  property :json_api_key, exec_context: :decorator

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

end