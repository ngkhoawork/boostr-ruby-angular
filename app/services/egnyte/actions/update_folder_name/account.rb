class Egnyte::Actions::UpdateFolderName::Account < Egnyte::Actions::UpdateFolderName::Base
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id client_id)
  end

  private

  def root_folder_path
    @root_folder_path ||= File.join(parent_folder_path, 'Accounts', record.name)
  end

  def parent_folder_path
    ensure_folders = @options[:parent_changed] || egnyte_folder&.path.nil?

    build_parent_folder_path(ensure_folders)
  end

  def build_parent_folder_path(ensure_folders)
    return Egnyte::PrivateActions::BuildAccountFolderPath.app_folder_path unless record.parent_client_id

    Egnyte::PrivateActions::BuildAccountFolderPath.new(
      client_id: record.parent_client_id,
      ensure_folders: ensure_folders
    ).perform
  end

  def record
    @record ||= Client.find(@options[:client_id])
  end
end
