class Egnyte::Actions::CreateFolderTree::Account < Egnyte::Actions::CreateFolderTree::Base
  class << self
    def folder_tree_attribute_name
      :account_folder_tree
    end

    def root_folder_path_prefix
      'Shared/Accounts'
    end
  end

  private

  delegate :folder_tree_attribute_name, :root_folder_path_prefix, to: self
end
