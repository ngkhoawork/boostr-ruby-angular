class Egnyte::Endpoints::Net
  PAYLOAD_SUPPORTED_METHODS = %i(post put patch).freeze
  SUCCESS_STATUS_CODES = %w(200 201 204)
  CONFIGS = {
    client_id: ENV['egnyte_client_id'],
    client_secret: ENV['egnyte_client_secret']
  }.freeze

  attr_reader :response, :parsed_response_body
  delegate :code, to: :response, prefix: true, allow_nil: true

  def perform
    @response = send_request.tap do |response|
      @parsed_response_body = response.body.present? ? JSON.parse(response.body, symbolize_names: true) : {}
    end
  end

  def success?
    SUCCESS_STATUS_CODES.include?(response_code)
  end

  private

  def send_request
    Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(build_request_object)
    end
  end

  def build_request_object
    net_http_class.new(uri).tap do |request_object|
      request_object.body = payload if PAYLOAD_SUPPORTED_METHODS.include?(request_method)
      request_headers.each { |key, value| request_object[key] = value }
    end
  end

  def net_http_class
    "Net::HTTP::#{request_method.to_s.capitalize}".constantize
  end

  def uri
    @uri ||= URI("https://#{domain}/#{path}").tap do |uri|
      uri.query = URI.encode_www_form(request_params) unless PAYLOAD_SUPPORTED_METHODS.include?(request_method)
    end
  end

  def payload
    request_params.to_json
  end

  def request_params
    {}
  end

  def request_headers
    {}
  end

  def request_method
    raise NotImplementedError, __method__
  end

  def domain
    raise NotImplementedError, __method__
  end

  def path
    raise NotImplementedError, __method__
  end
end
