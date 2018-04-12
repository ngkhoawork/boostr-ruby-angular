class Egnyte::Actions::GetNavigateUri::Deal < Egnyte::Actions::GetNavigateUri::Base
  def self.required_option_keys
    @required_option_keys ||= %i(egnyte_integration_id deal_id)
  end

  private

  def record
    Deal.find(@options[:deal_id])
  end

  def folder_path
    egnyte_folder.path
  end
end
