class Hoopla::Endpoints::Request
  HOST = 'https://api.hoopla.net'.freeze
  PAYLOAD_METHODS = %i(post put patch).freeze

  delegate :net_options, :required_option_keys, to: :class

  def self.net_options
    {
      use_ssl: true,
      verify_mode: OpenSSL::SSL::VERIFY_NONE
    }
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  def perform
    Egnyte::Endpoints::Response.new(send_request)
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
    @uri ||= URI(hosted_path).tap do |uri|
      uri.query = URI.encode_www_form(request_params) unless PAYLOAD_METHODS.include?(request_method)
    end
  end

  def hosted_path
    path.start_with?(HOST) ? path : "#{HOST}/#{path}"
  end

  def net_http_class
    "Net::HTTP::#{request_method.to_s.capitalize}".constantize
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
