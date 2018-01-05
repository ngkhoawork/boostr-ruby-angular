class Api::Publishers::ContactsSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :note,
    :email,
    :primary_client_contact,
    :name,
    :activity_updated_at,
    :phone,
    :client,
    :address,
    :publisher,
    :contact_cf,
    :publisher_id
  )

  private

  def primary_client_contact
    object.primary_client_contact&.serializable_hash(only: [:id, :name, :primary, :is_active, :client_id])
  end

  def client
    object.client&.serializable_hash(only: [:id, :name])
  end

  def publisher
    object.publisher&.serializable_hash(only: [:id, :name])
  end
end
