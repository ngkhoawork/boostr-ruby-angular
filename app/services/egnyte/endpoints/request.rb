class Egnyte::Endpoints::Request
  PAYLOAD_METHODS = %i(post put patch).freeze
  ENCODED_SPACE_SIGN = '%20'.freeze
  MAX_REQUEST_RETRY_COUNTS = 3

  delegate :api_credentials, :net_options, :required_option_keys, to: :class

  class << self
    def api_credentials
      {
        client_id: ENV['egnyte_client_id']         || (raise 'ENV[egnyte_client_id] has not been provided'),
        client_secret: ENV['egnyte_client_secret'] || (raise 'ENV[egnyte_client_secret] has not been provided')
      }
    end

    def net_options
      {
        use_ssl: true,
        verify_mode: OpenSSL::SSL::VERIFY_NONE
      }
    end
  end

  def initialize(domain, options)
    @domain = domain
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  def perform
    response = Egnyte::Endpoints::Response.new(send_request)

    @request_retry_count = 0
    while retry_after_queries_rate_exceeded?(response)
      @request_retry_count += 1
      sleep(0.5)

      response = Egnyte::Endpoints::Response.new(send_request)
    end

    response
  end

  private

  def send_request
    Net::HTTP.start(uri.hostname, uri.port, net_options) do |http|
      http.request(build_request_object)
    end
  end

  def build_request_object
    net_http_class.new(uri).tap do |request_object|
      request_object.body = payload if PAYLOAD_METHODS.include?(request_method)
      request_headers.each { |key, value| request_object[key] = value }
    end
  end

  def uri
    @uri ||= URI("https://#{@domain}/#{encoded_path}").tap do |uri|
      uri.query = URI.encode_www_form(request_params) unless PAYLOAD_METHODS.include?(request_method)
    end
  end

  def net_http_class
    "Net::HTTP::#{request_method.to_s.capitalize}".constantize
  end

  def retry_after_queries_rate_exceeded?(response)
    response.forbidden? && @request_retry_count < MAX_REQUEST_RETRY_COUNTS
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
end
