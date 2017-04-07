class DFP::DfpLoggerService < BaseService

  def create_log!
    IntegrationLog.create!(
        request_body: parsed_request.body,
        company_id: company_id,
        api_provider: 'dfp',
        response_body: parsed_response.body
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