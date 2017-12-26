class ClientContacts::ConnectedClientSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name
  )
end
