class Operative::IntegrationLoggingMiddleware < Faraday::Middleware
  def initialize(app)
    @app = app
  end

  def call(request_env)
    @app.call(request_env).on_complete do |response_env|

      integration_log = IntegrationLog.new

      puts request_env

      unless response_env.body.kind_of? Hash
        parsed_xml = Nokogiri::XML response_env.body
        root_element = parsed_xml.root.name
        parsed_xml.remove_namespaces!

        if parsed_xml.xpath("//error").length > 0
          integration_log.is_error = true
          if root_element == 'GlobalResponse'
            integration_log.error_text = parsed_xml.xpath("//error/@text").text
          else
            integration_log.error_text = parsed_xml.xpath("//error/message").text
          end
        else
          integration_log.is_error = false
        end
      end

      integration_log.object_name   = request_env.request_headers['resourceName']
      integration_log.api_provider  = request_env.request_headers['apiProvider']
      integration_log.response_code = response_env.response.status
      integration_log.response_body = response_env.response.body
      integration_log.api_endpoint  = response_env.response.env.url.to_s
      integration_log.request_type  = request_env.method.to_s
      integration_log.response_body = response_env.response.body
      integration_log.company_id    = request_env.request_headers['companyId']
      integration_log.deal_id       = request_env.request_headers['dealId']

      integration_log.save
    end
  end
end