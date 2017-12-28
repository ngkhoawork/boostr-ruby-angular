class Api::V2::ActivityTypeSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :action,
    :icon,
    :position,
    :active,
    :css_class
  )
end
