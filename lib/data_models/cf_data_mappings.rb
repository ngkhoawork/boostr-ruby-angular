class DataModels::CfDataMappings < DataModels::Base
  def self.config_json_path
    "#{Rails.root}/config/custom_fields_data_mappings.json"
  end
end
