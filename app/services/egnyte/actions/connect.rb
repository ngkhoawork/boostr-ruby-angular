class Egnyte::Actions::Connect < Egnyte::Actions::Base
  APP_FOLDER_PATH = '/Shared/Boostr'.freeze

  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id state code auth_record_type redirect_uri)
  end

  def perform
    raise Egnyte::Errors::InvalidAuthState unless auth_record

    response = api_caller.oauth(code: @options[:code], redirect_uri: @options[:redirect_uri])

    if response.success?
      auth_record.update(access_token: response.body[:access_token], state_token: nil)

      api_caller.create_folder(folder_path: APP_FOLDER_PATH, access_token: access_token)
    else
      raise Egnyte::Errors::UnhandledRequest, response.body
    end
  end

  private

  delegate :access_token, to: :auth_record

  def auth_record
    @auth_record ||= @options[:auth_record_type].constantize.find_by(state_token: @options[:state])
  end
end
