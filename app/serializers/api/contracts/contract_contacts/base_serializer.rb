class Api::Contracts::ContractContacts::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :contact,
    :role
  )

  private

  def contact
    object.contact&.serializable_hash(only: [:id, :name, :position], methods: [:client_name, :email])
  end

  def role
    object.role&.serializable_hash(only: [:id, :name])
  end
end
