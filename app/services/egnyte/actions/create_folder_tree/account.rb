class Egnyte::Actions::CreateFolderTree::Account < Egnyte::Actions::CreateFolderTree::Base
  class << self
    private

    def folder_tree_attribute_name
      :account_folder_tree
    end

    def folder_path_prefix
      'Shared/Accounts'
    end
  end
end
