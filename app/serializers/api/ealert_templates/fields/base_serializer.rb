class Api::EalertTemplates::Fields::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :position
  )
end
