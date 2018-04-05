class Egnyte::PrivateActions::EnsureAccountFolder < Egnyte::PrivateActions::Base
  def self.required_option_keys
    @required_option_keys ||= %i(client_id pattern_path)
  end

  def perform
    egnyte_folder ? refresh_folder_path : create_folder_and_save_path

    egnyte_folder.path
  end

  private

  delegate :access_token, :app_domain, to: :egnyte_integration

  def refresh_folder_path
    if get_folder_by_id_response.success?
      folder = get_folder_by_id_response.body
      egnyte_folder.update!(uuid: folder[:folder_id], path: folder[:path])
    elsif get_folder_by_id_response.not_found?
      egnyte_folder.destroy!
      create_folder_and_save_path
    else
      raise Egnyte::Errors::UnhandledRequest, get_folder_by_id_response.body
    end
  end

  def create_folder_and_save_path
    create_folder_response

    folder = get_folder_by_path_response.body

    record.create_egnyte_folder!(uuid: folder[:folder_id], path: folder[:path])
  end

  def get_folder_by_id_response
    @get_folder_by_id_response ||=
      Egnyte::Endpoints::GetFolderById.new(
        app_domain,
        folder_id: egnyte_folder.uuid,
        access_token: access_token
      ).perform
  end

  def create_folder_response
    Egnyte::Endpoints::CreateFolder.new(
      app_domain,
      folder_path: @options[:pattern_path],
      access_token: access_token
    ).perform
  end

  def get_folder_by_path_response
    Egnyte::Endpoints::GetFolderByPath.new(
      app_domain,
      folder_path: @options[:pattern_path],
      access_token: access_token
    ).perform
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
