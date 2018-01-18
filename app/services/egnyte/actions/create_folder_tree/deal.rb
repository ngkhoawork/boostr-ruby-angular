class Egnyte::Actions::CreateFolderTree::Deal < Egnyte::Actions::CreateFolderTree::Base
  class << self
    private

    def folder_tree_attribute_name
      :deal_folder_tree
    end

    def folder_path_prefix
      'Shared/Deals'
    end
  end
end
