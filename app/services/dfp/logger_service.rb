class DFP::LoggerService < BaseService

  def create_log!
    IntegrationLog.create!(
        request_body: parsed_request.body,
        company_id: company_id,
        api_endpoint: parsed_request.endpoint,
        api_provider: 'dfp',
        response_body: parsed_response.body,
        response_code: parsed_response.status,
        is_error: parsed_response.is_error,
        object_name: parsed_request.api_method + "(#{dfp_query_type} report)",
        dfp_query_type: dfp_query_type
    )
  end

  private

  def parsed_response
    DfpApi::ApiResponseSerializer.new(response)
  end

  def parsed_request
    DfpApi::ApiRequestSerializer.new(request)
  end

end