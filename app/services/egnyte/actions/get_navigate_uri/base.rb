class Egnyte::Actions::GetNavigateUri::Base < Egnyte::Actions::Base
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id user_auth_id)
  end

  def perform
    return unless enabled? && user_auth.passed? && folder

    if folder.path
      navigate || update_path_and_navigate
    else
      update_path_and_navigate
    end
  end

  private

  delegate :access_token, to: :user_auth

  def navigate
    response = api_caller.navigate(folder_path: folder_path, access_token: access_token)

    if response.success?
      response.body[:redirect]
    elsif response.bad_request?
      nil
    else
      raise Egnyte::Errors::UnhandledRequest
    end
  end

  def update_path_and_navigate
    update_folder_path

    navigate
  end

  def update_folder_path
    response = api_caller.get_folder_by_id(folder_id: folder.uuid, access_token: access_token)

    folder.update(path: response.body[:path])
  end

  def folder
    @folder ||= record.egnyte_folder
  end

  def user_auth
    @user_auth ||= EgnyteAuthentication.find(@options[:user_auth_id])
  end
end
