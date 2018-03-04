class Egnyte::Actions::UpdateFolderName::Deal < Egnyte::Actions::UpdateFolderName::Base
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id deal_id)
  end

  private

  def root_folder_path
    "/Shared/Accounts/#{record.advertiser_name}/Deals/#{record.name}"
  end

  def record
    @record ||= Deal.find(@options[:deal_id])
  end
end
