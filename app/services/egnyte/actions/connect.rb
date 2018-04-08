class Egnyte::Actions::Connect < Egnyte::Actions::Base
  APP_FOLDER_PATH = '/Shared/Boostr'.freeze

  def self.required_option_keys
    @required_option_keys ||= %i(code redirect_uri state)
  end

  def perform
    raise Egnyte::Errors::InvalidAuthState unless egnyte_integration

    response = api_caller.oauth(redirect_uri: @options[:redirect_uri], code: @options[:code])

    if response.success?
      egnyte_integration.update(
        connected: true,
        access_token: response.body[:access_token]
      )
      api_caller.create_folder(folder_path: APP_FOLDER_PATH, access_token: access_token)
    else
      raise Egnyte::Errors::UnhandledRequest, response.body
    end
  end
end
