class Egnyte::Endpoints::Oauth < Egnyte::Endpoints::Request
  class << self
    def required_option_keys
      %i(redirect_uri code)
    end

    def predefined_request_params
      {
        scope: 'Egnyte.filesystem Egnyte.launchwebsession',
        grant_type: 'authorization_code'
      }
    end
  end

  private

  delegate :predefined_request_params, to: :class

  def request_method
    :post
  end

  def path
    'puboauth/token'
  end

  def payload
    URI.encode_www_form(request_params)
  end

  def request_params
    {
      code: @options[:code],
      redirect_uri: @options[:redirect_uri],
      client_id: api_credentials[:client_id],
      client_secret: api_credentials[:client_secret],
      scope: predefined_request_params[:scope],
      grant_type: predefined_request_params[:grant_type]
    }
  end
end
