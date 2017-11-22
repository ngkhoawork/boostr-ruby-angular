class Inactives::LastActivitySerializer < ActiveModel::Serializer
  attributes(
    :id,
    :happened_at,
    :activity_type_name,
    :comment
  )
end
