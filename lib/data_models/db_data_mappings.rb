class DataModels::DbDataMappings < DataModels::Base
  def self.config_json_path
    "#{Rails.root}/config/data_mappings.json"
  end
end
