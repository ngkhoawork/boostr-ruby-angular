class Egnyte::Endpoints::Oauth < Egnyte::Endpoints::Net
  class << self
    def required_option_keys
      %i(domain redirect_uri code)
    end

    def predefined_request_params
      {
        scope: 'Egnyte.filesystem Egnyte.launchwebsession',
        grant_type: 'authorization_code'
      }
    end
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_key| raise "#{option_key} is required" unless @options[option_key] }
  end

  private

  delegate :required_option_keys, :predefined_request_params, to: self

  def request_method
    :post
  end

  def domain
    @options[:domain].sub(/https?:\/\//, '')
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
      client_id: CONFIGS[:client_id],
      client_secret: CONFIGS[:client_secret],
      scope: predefined_request_params[:scope],
      grant_type: predefined_request_params[:grant_type]
    }
  end
end
