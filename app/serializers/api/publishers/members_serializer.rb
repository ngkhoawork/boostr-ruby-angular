class Api::Publishers::MembersSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :user_id,
    :owner,
    :name,
    :member_role
  )

  def member_role
    object.role.as_json(only: [:id, :name])
  end
end
