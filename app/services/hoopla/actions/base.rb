class Hoopla::Actions::Base
  def self.required_option_keys
    %i(company_id)
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_name| raise "#{option_name} is required" unless @options[option_name] }

    @options[:client_id] = configuration.client_id
    @options[:client_secret] = configuration.client_secret
    @options[:access_token] = ensure_access_token
  end

  private

  delegate :required_option_keys, to: :class

  def api_caller
    Hoopla::Endpoints::ApiCaller
  end

  def ensure_access_token
    configuration.access_token_alive? ? configuration.access_token : get_access_token
  end

  def get_access_token
    response = api_caller.oauth(@options)

    if response.success?
      configuration.update!(
        access_token: response.body[:access_token],
        access_token_expires_at: DateTime.current + response.body[:expires_in].seconds,
        connected: true
      )
      response.body[:access_token]
    else
      raise Hoopla::Errors::AuthFailed, 'credentials are invalid'
    end
  end

  def configuration
    @configuration ||=
      HooplaConfiguration.find_by(company_id: @options[:company_id]) || (raise 'hoopla configuration does not exist')
  end
end
