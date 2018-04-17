class Egnyte::Actions::BuildAuthorizationUri < Egnyte::Actions::Base
  class << self
    def required_option_keys
      @required_option_keys ||= %i(domain redirect_uri auth_record)
    end

    def predefined_request_params
      {
        scope: 'Egnyte.filesystem Egnyte.launchwebsession',
        response_code: 'code'
      }
    end

    delegate :api_credentials, to: Egnyte::Endpoints::Request
  end

  def perform
    @options[:auth_record].update(access_token: nil, state_token: state_token)

    "https://#{@options[:domain]}/puboauth/token?#{url_embedded_request_params}"
  end

  private

  delegate :api_credentials, :predefined_request_params, to: :class

  def url_embedded_request_params
    request_params.map { |key, value| "#{key}=#{value}" }.join('&')
  end

  def request_params
    {
      state: state_token,
      redirect_uri: @options[:redirect_uri],
      scope: predefined_request_params[:scope],
      response_type: predefined_request_params[:response_code],
      client_id: api_credentials[:client_id],
      client_secret: api_credentials[:client_secret]
    }
  end

  def state_token
    @state_token ||= Digest::MD5.hexdigest("#{DateTime.current}-#{@options[:domain]}")
  end
end
