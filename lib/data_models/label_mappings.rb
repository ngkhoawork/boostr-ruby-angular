class DataModels::LabelMappings < DataModels::Base
  def self.config_json_path
    "#{Rails.root}/config/label_mappings.json"
  end
end
