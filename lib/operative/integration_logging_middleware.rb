class Operative::IntegrationLoggingMiddleware < Faraday::Middleware
  def initialize(app)
    @app = app
  end

  def call(request_env)
    # hook logger on request complete
    @app.call(request_env).on_complete do |response_env|

      detect_errors(response_env)
      compose_log_object(request_env, response_env)

      integration_log.save!
    end
  end

  private

  def integration_log
    @integration_log ||= IntegrationLog.new(log_params)
  end

  def log_params
    @log_params ||= {}
  end

  def detect_errors(response_env)
    parsed_xml = Nokogiri::XML response_env.body
    root_element = parsed_xml.root.name
    # remove namespaces from incoming XML for better v2 parsing
    parsed_xml.remove_namespaces!

    # detect if response body contains any error tag
    if parsed_xml.xpath("//error").length > 0
      log_params[:is_error] = true

      # get error text from v2 response
      if root_element == 'GlobalResponse'
        log_params[:error_text] = parsed_xml.xpath("//error/@text").text
      # get error from v1 response
      else
        log_params[:error_text] = parsed_xml.xpath("//error/message").text
      end
    else
      log_params[:is_error] = false
    end
  end

  def compose_log_object(request_env, response_env)
    log_params[:object_name]   = request_env.request_headers['resourceName']
    log_params[:api_provider]  = request_env.request_headers['apiProvider']
    log_params[:request_type]  = request_env.method.to_s
    log_params[:company_id]    = request_env.request_headers['companyId']
    log_params[:deal_id]       = request_env.request_headers['dealId']
    log_params[:response_code] = response_env.response.status
    log_params[:response_body] = response_env.response.body
    log_params[:api_endpoint]  = response_env.response.env.url.to_s
    log_params[:response_body] = response_env.response.body
  end
end