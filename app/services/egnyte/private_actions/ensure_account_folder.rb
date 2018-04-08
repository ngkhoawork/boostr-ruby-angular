class Egnyte::PrivateActions::EnsureAccountFolder < Egnyte::Actions::Base
  def self.required_option_keys
    @required_option_keys ||= %i(client_id pattern_path)
  end

  def perform
    egnyte_folder ? refresh_folder_path : create_folder

    egnyte_folder.path
  end

  private

  def refresh_folder_path
    response = api_caller.get_folder_by_id(folder_id: egnyte_folder.uuid, access_token: access_token)

    if response.success?
      egnyte_folder.update!(uuid: response.body[:folder_id], path: response.body[:path])
    elsif response.not_found?
      recreate_folder
    else
      raise Egnyte::Errors::UnhandledRequest, response.body
    end
  end

  def create_folder
    api_caller.create_folder(folder_path: @options[:pattern_path], access_token: access_token)

    response = api_caller.get_folder_by_path(folder_path: @options[:pattern_path], access_token: access_token)

    record.create_egnyte_folder!(uuid: response.body[:folder_id], path: response.body[:path])
  end

  def recreate_folder
    egnyte_folder.destroy!
    create_folder
  end

  def record
    @record ||= Client.find(@options[:client_id])
  end

  def egnyte_folder
    record.egnyte_folder
  end

  def egnyte_integration
    record.company&.egnyte_integration
  end
end
