class DataModels::ReflectionMappings < DataModels::Base
  def self.config_json_path
    "#{Rails.root}/config/reflection_mappings.json"
  end
end
