class Egnyte::PrivateActions::EnsureAccountFolder < Egnyte::Actions::Base
  def self.required_option_keys
    @required_option_keys ||= %i(client_id pattern_path)
  end

  def perform
    folder ? refresh_folder_path : create_folder

    folder.path
  end

  private

  def refresh_folder_path
    response = api_caller.get_folder_by_id(folder_id: folder.uuid, access_token: access_token)

    if response.success?
      folder.update!(uuid: response.body[:folder_id], path: response.body[:path])
    elsif response.not_found?
      recreate_folder
    else
      raise Egnyte::Errors::UnhandledRequest, response.body
    end
  end

  def create_folder
    uniq_path =
      Egnyte::PrivateActions::CreateUniqFolder.new(
        path: @options[:pattern_path],
        egnyte_integration: egnyte_integration
      ).perform

    response = api_caller.get_folder_by_path(folder_path: uniq_path, access_token: access_token)

    record.create_egnyte_folder!(uuid: response.body[:folder_id], path: response.body[:path])
  end

  def recreate_folder
    folder.destroy!
    create_folder
  end

  def record
    @record ||= Client.find(@options[:client_id])
  end

  def folder
    record.egnyte_folder
  end

  def egnyte_integration
    record.company&.egnyte_integration
  end
end
