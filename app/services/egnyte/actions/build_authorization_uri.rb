class Egnyte::Actions::BuildAuthorizationUri < Egnyte::Actions::Base
  REQUESTED_ACCESS_TOKEN_MARKER = 'SHOULD_BE_REPLACED_WITH_ACCESS_TOKEN'.freeze

  class << self
    def generate_state_token(salt)
      random_hash = Digest::MD5.hexdigest("#{DateTime.current}-#{salt}")

      "#{REQUESTED_ACCESS_TOKEN_MARKER}_#{random_hash}"
    end

    def required_option_keys
      @required_option_keys ||= %i(domain redirect_uri state)
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
    "https://#{@options[:domain]}/puboauth/token?#{url_embedded_request_params}"
  end

  private

  delegate :api_credentials, :predefined_request_params, to: :class

  def url_embedded_request_params
    request_params.map { |key, value| "#{key}=#{value}" }.join('&')
  end

  def request_params
    {
      redirect_uri: @options[:redirect_uri],
      state: @options[:state],
      client_id: api_credentials[:client_id],
      client_secret: api_credentials[:client_secret],
      scope: predefined_request_params[:scope],
      response_type: predefined_request_params[:response_code]
    }
  end
end
