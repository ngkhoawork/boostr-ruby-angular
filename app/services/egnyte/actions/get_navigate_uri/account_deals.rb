class Egnyte::Actions::GetNavigateUri::AccountDeals < Egnyte::Actions::GetNavigateUri::Base
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id advertiser_id)
  end

  private

  def record
    Client.find(@options[:advertiser_id])
  end

  def folder_path
    File.join(egnyte_folder.path, deals_folder_name)
  end
end
