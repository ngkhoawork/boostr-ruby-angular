class ClientContacts::ConnectedContactSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :address,
    :position
  )

  has_one :primary_client, serializer: ClientContacts::ConnectedClientSerializer

  def address
    object.address.serializable_hash(only: [:email, :mobile])
  end
end
