class Egnyte::Actions::CreateFolderTree::Account < Egnyte::Actions::CreateFolderTree::Base
  class << self
    def required_option_keys
      @required_option_keys ||= %i(egnyte_integration_id advertiser_id)
    end

    def folder_tree_attr_name
      :account_folder_tree
    end
  end

  private

  delegate :accounts_folder_path, to: :class

  def root_folder_path
    @root_folder_path ||= File.join(parent_folder_path, 'Accounts', record.name)
  end

  def parent_folder_path
    Egnyte::PrivateActions::BuildAccountFolderPath.new(client_id: record.parent_client_id, ensure_folders: true).perform
  end

  def record
    @record ||= Client.find(@options[:advertiser_id])
  end
end
