class DataModels::ReflectionLabelMappings < DataModels::Base
  def self.config_json_path
    "#{Rails.root}/config/reflection_label_mappings.json"
  end
end
