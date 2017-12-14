class Hoopla::Endpoints::Oauth < Hoopla::Endpoints::Request
  GRANT_TYPE = 'client_credentials'.freeze

  def self.required_option_keys
    %i(client_id client_secret)
  end

  private

  def build_request_object
    net_http_class.new(uri).tap do |request_object|
      request_object.set_form_data(request_params)
      request_headers.each { |key, value| request_object[key] = value }
    end
  end

  def request_method
    :post
  end

  def path
    'oauth2/token'
  end

  def request_params
    {
      grant_type: GRANT_TYPE,
      client_id: @options[:client_id],
      client_secret: @options[:client_secret]
    }
  end
end
