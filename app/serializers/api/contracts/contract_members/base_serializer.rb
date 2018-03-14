class Api::Contracts::ContractMembers::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :user,
    :role
  )

  private

  def user
    object.user&.serializable_hash(only: [:id, :name, :user_type])
  end

  def role
    object.role&.serializable_hash(only: [:id, :name])
  end
end
