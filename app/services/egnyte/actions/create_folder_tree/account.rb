class Egnyte::Actions::CreateFolderTree::Account < Egnyte::Actions::CreateFolderTree::Base
  class << self
    def required_option_keys
      @required_option_keys ||= %i(egnyte_integration_id advertiser_name)
    end

    def folder_tree_attribute_name
      :account_folder_tree
    end
  end

  private

  def root_folder_path
    "Shared/Accounts/#{encoded_advertiser_name}"
  end

  def encoded_advertiser_name
    encode_space_sign(@options[:advertiser_name])
  end
end
