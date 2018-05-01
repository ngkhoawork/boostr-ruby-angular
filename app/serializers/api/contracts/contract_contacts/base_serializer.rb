class Api::Contracts::ContractContacts::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :contact_id,
    :contact_name,
    :contact_position,
    :contact_client_name,
    :contact_email
  )

  private

  def contact_name
    object.contact&.name
  end

  def contact_position
    object.contact&.position
  end

  def contact_client_name
    object.contact&.client_name
  end

  def contact_email
    object.contact&.email
  end
end
