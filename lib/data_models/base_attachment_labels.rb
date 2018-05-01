class DataModels::BaseAttachmentLabels < DataModels::Base
  def self.config_json_path
    Rails.root.join('config', 'base_attachment_labels.json').to_s
  end
end
