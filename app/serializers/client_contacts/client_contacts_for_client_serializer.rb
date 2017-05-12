class ClientContacts::ClientContactsForClientSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :client_id,
    :contact_id,
    :primary,
    :is_active
  )

  has_one :contact, serializer: ClientContacts::ContactSerializer, contact_options: @options
end
