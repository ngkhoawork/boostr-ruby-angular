class Pmps::PmpMemberSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :user_id,
    :pmp_id,
    :share,
    :from_date,
    :to_date,
    :user
  )

  def user
    object.user.serializable_hash(only: [:id, :name, :email]) rescue nil
  end
end
