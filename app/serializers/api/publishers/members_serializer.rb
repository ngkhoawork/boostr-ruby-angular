class Api::Publishers::MembersSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :user_id,
    :owner,
    :name
  )
end
