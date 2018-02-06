class Egnyte::Actions::CreateFolderTree::Deal < Egnyte::Actions::CreateFolderTree::Base
  class << self
    def folder_tree_attribute_name
      :deal_folder_tree
    end

    def root_folder_path_prefix
      'Shared/Deals'
    end
  end

  private

  delegate :folder_tree_attribute_name, :root_folder_path_prefix, to: self
end
