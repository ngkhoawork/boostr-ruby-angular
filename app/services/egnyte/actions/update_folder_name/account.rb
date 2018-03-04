class Egnyte::Actions::UpdateFolderName::Account < Egnyte::Actions::UpdateFolderName::Base
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id advertiser_id)
  end

  private

  def root_folder_path
    "/Shared/Accounts/#{record.name}"
  end

  def record
    @record ||= Client.find(@options[:advertiser_id])
  end
end
