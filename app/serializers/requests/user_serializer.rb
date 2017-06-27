class Requests::UserSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name
  )
end
