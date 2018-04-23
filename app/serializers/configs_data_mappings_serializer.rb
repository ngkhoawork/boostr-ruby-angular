class ConfigsDataMappingsSerializer < ActiveModel::Serializer
  attributes :name,
             :label_name

  private

  def name
    object
  end

  def label_name
    DataModels::BaseAttachmentLabels.parsed_json[object]
  end
end
