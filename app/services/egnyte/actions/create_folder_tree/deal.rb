class Egnyte::Actions::CreateFolderTree::Deal < Egnyte::Actions::CreateFolderTree::Base
  class << self
    def required_option_keys
      @required_option_keys ||= %i(egnyte_integration_id deal_id)
    end

    def folder_tree_attr_name
      :deal_folder_tree
    end
  end

  private

  def root_folder_path
    @root_folder_path ||= File.join(parent_folder_path, deals_folder_name, record.name)
  end

  def parent_folder_path
    Egnyte::PrivateActions::BuildAccountFolderPath.new(client_id: record.advertiser_id, ensure_folders: true).perform
  end

  def record
    @record ||= Deal.find(@options[:deal_id])
  end
end
