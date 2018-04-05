class Egnyte::Actions::Connect
  APP_FOLDER_PATH = '/Shared/Boostr'.freeze

  def self.required_option_keys
    @required_option_keys ||= %i(code redirect_uri state)
  end

  def initialize(options)
    @options = options.deep_symbolize_keys

    required_option_keys.each { |option_name| raise "#{option_name} is required" unless @options[option_name] }
  end

  def perform
    raise Egnyte::Errors::InvalidAuthState unless egnyte_integration

    if oauth_response.success?
      egnyte_integration.update(
        connected: true,
        access_token: oauth_response.body[:access_token]
      )
      create_app_folder_response
    else
      raise Egnyte::Errors::UnhandledRequest, oauth_response.body
    end
  end

  private

  delegate :required_option_keys, to: :class
  delegate :access_token, :app_domain, :enabled_and_connected?, to: :egnyte_integration

  def oauth_response
    @oauth_response ||= Egnyte::Endpoints::Oauth.new(
      app_domain,
      redirect_uri: @options[:redirect_uri],
      code: @options[:code]
    ).perform
  end

  def create_app_folder_response
    Egnyte::Endpoints::CreateFolder.new(
      app_domain,
      folder_path: APP_FOLDER_PATH,
      access_token: access_token
    ).perform
  end

  def egnyte_integration
    @egnyte_integration ||= EgnyteIntegration.find_by_state_token(@options[:state])
  end
end
