class Api::Publishers::ContactsSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :note,
    :email,
    :primary_client_contact
  )

  private

  def primary_client_contact
    object.primary_client_contact&.serializable_hash(only: [:id, :name, :primary, :is_active, :client_id])
  end
end
