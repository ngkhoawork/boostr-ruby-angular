class ConfigsDataMappingsSerializer < ActiveModel::Serializer
  attributes :name,
             :label_name

  private

  def name
    object
  end

  def label_name
    label = DataModels::BaseAttachmentLabels.parsed_json[object.to_sym]
    return label if label.present?
    object.split('.').map(&:humanize).map(&:titleize).join(' ')
  end
end
