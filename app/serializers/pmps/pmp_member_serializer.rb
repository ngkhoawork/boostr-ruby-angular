class Pmps::PmpMemberSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :user_id,
    :pmp_id,
    :name,
    :share,
    :from_date,
    :to_date,
    :user
  )

  def name
    object.user.name rescue nil
  end
  
  def user
    object.user.serializable_hash(only: [:id, :email]) rescue nil
  end
end
