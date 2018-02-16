class Dataexport::IoMemberSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :io_id, :user_id, :share, :from_date, :to_date, :created, :last_updated
end
