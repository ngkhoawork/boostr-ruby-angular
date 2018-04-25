class Egnyte::Actions::Connect::Base < Egnyte::Actions::Base
  APP_FOLDER_PATH = '/Shared/Boostr'.freeze

  def self.required_option_keys
    @required_option_keys ||= %i(state code redirect_uri)
  end

  def perform
    raise Egnyte::Errors::InvalidAuthState, "can not match #{@options[:state]}" unless auth_record

    if oauth_response.success?
      auth_record.update(access_token: oauth_response.body[:access_token], state_token: nil)

      api_caller.create_folder(folder_path: APP_FOLDER_PATH, access_token: access_token)
    else
      raise Egnyte::Errors::UnhandledRequest, oauth_response.body
    end
  end

  private

  delegate :access_token, to: :auth_record

  def auth_record
    @auth_record ||= auth_class.find_by(state_token: @options[:state])
  end

  def oauth_response
    @oauth_response ||= api_caller.oauth(code: @options[:code], redirect_uri: @options[:redirect_uri])
  end
end
