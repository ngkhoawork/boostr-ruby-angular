class Egnyte::Endpoints::Net
  CONFIGS = {
    client_id: ENV['egnyte_client_id'],
    client_secret: ENV['egnyte_client_secret']
  }.freeze
  PAYLOAD_SUPPORTED_METHODS = %i(post put patch).freeze
  STATUS_CODES = {
    success: %w(200 201 204),
    queries_rate_exceeded: %w(403),
    not_found: %w(404)
  }.freeze
  ENCODED_SPACE_SIGN = '%20'.freeze
  MAX_REQUEST_RETRY_COUNTS = 3

  attr_reader :response

  delegate :net_options, to: :class
  delegate :code, to: :response, prefix: true, allow_nil: true

  def self.net_options
    {
      use_ssl: true,
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  end

  def perform
    @response = send_request

    @request_retry_count = 0
    while retry_after_queries_rate_exceeded?
      @request_retry_count += 1
      sleep(0.5)

      @response = send_request
    end

    @response
  end

  def success?
    STATUS_CODES[:success].include?(response_code)
  end

  def not_found?
    STATUS_CODES[:not_found].include?(response_code)
  end

  def parsed_response_body
    @parsed_response_body ||= JSON.parse(@response.body, symbolize_names: true) if @response&.body.present?
  end

  private

  def send_request
    Net::HTTP.start(uri.hostname, uri.port, net_options) do |http|
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

  def retry_after_queries_rate_exceeded?
    @request_retry_count < MAX_REQUEST_RETRY_COUNTS && STATUS_CODES[:queries_rate_exceeded].include?(@response.code)
  end

  def uri
    @uri ||= URI("https://#{domain}/#{encoded_path}").tap do |uri|
      uri.query = URI.encode_www_form(request_params) unless PAYLOAD_SUPPORTED_METHODS.include?(request_method)
    end
  end

  def encoded_path
    path.gsub(/ /, ENCODED_SPACE_SIGN)
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

  def domain
    @options[:domain].sub(/https?:\/\//, '')
  end

  def request_method
    raise NotImplementedError, __method__
  end

  def path
    raise NotImplementedError, __method__
  end
end
