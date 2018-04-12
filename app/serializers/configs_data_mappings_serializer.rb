class ConfigsDataMappingsSerializer < ActiveModel::Serializer
  attributes :name,
             :label_name

  private

  def name
    object
  end

  def label_name
    object.split('.').map(&:humanize).map(&:titleize).join(' ')
  end
end
