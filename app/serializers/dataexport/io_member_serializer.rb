class Dataexport::IoMemberSerializer < ActiveModel::Serializer
  attributes :id, :io_id, :user_id, :share, :from_date, :to_date, :created, :last_updated

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end
end
