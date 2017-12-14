class ClientContacts::ConnectedClientContactsSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :client_id,
    :contact_id,
    :is_active
  )

  has_one :contact, serializer: ClientContacts::ConnectedContactSerializer
  has_one :client,  serializer: ClientContacts::ConnectedClientSerializer
end
