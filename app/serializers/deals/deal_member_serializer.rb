class Deals::DealMemberSerializer < ActiveModel::Serializer
  attributes :id, :user_id, :share, :name
end
