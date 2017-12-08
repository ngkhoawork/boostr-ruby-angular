class ClientContacts::ConnectedContactSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :address,
    :position
  )

  def address
    object.address.serializable_hash(only: [:email, :mobile])
  end
end
