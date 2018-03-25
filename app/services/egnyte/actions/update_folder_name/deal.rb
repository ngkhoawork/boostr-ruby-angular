class Egnyte::Actions::UpdateFolderName::Deal < Egnyte::Actions::UpdateFolderName::Base
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id deal_id)
  end

  private

  def root_folder_path
    @root_folder_path ||= File.join(parent_folder_path, deals_folder_name, record.name)
  end

  def parent_folder_path
    ensure_folders = @options[:advertiser_changed] || egnyte_folder&.path.nil?

    build_parent_folder_path(ensure_folders)
  end

  def build_parent_folder_path(ensure_folders)
    Egnyte::PrivateActions::BuildAccountFolderPath.new(
      client_id: record.advertiser_id,
      ensure_folders: ensure_folders
    ).perform
  end

  def record
    @record ||= Deal.find(@options[:deal_id])
  end
end
