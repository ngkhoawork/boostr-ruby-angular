class DataModels::BaseLabels < DataModels::Base
  def self.config_json_path
    Rails.root.join('config', 'base_labels.json').to_s
  end
end
