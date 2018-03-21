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
    if get_folder_by_id_request.success?
      folder_info = get_folder_by_id_request.parsed_response_body
      egnyte_folder.update!(uuid: folder_info[:folder_id], path: folder_info[:path])
    elsif get_folder_by_id_request.not_found?
      egnyte_folder.destroy!
      create_folder_and_save_path
    else
      raise get_folder_by_id_request.parsed_response_body
    end
  end

  def create_folder_and_save_path
    create_folder_request

    folder_info = get_folder_by_path_request.parsed_response_body

    record.create_egnyte_folder!(uuid: folder_info[:folder_id], path: folder_info[:path])
  end

  def get_folder_by_id_request
    @get_folder_by_id_request ||=
      Egnyte::Endpoints::GetFolderById.new(
        folder_id: egnyte_folder.uuid,
        domain: app_domain,
        access_token: access_token
      ).tap { |req| req.perform }
  end

  def create_folder_request
    Egnyte::Endpoints::CreateFolder.new(
      folder_path: @options[:pattern_path],
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
  end

  def get_folder_by_path_request
    Egnyte::Endpoints::GetFolderByPath.new(
      folder_path: @options[:pattern_path],
      domain: app_domain,
      access_token: access_token
    ).tap { |req| req.perform }
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
