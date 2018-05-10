class Api::Contracts::ContractMembers::BaseSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :user_id,
    :user_name,
    :user_type,
    :role_id,
    :role_name
  )

  private

  def user_name
    object.user&.name
  end

  def user_type
    object.user&.user_type
  end

  def role_name
    object.role&.name
  end
end
