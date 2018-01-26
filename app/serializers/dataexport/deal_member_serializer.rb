class Dataexport::DealMemberSerializer < ActiveModel::Serializer
  attributes :user_id, :share, :role
end
