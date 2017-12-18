class Ios::IoMemberSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :io_id,
    :user_id,
    :share,
    :from_date,
    :to_date,
    :created_at,
    :updated_at,
    :name
  )
end
