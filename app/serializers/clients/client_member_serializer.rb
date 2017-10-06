class Clients::ClientMemberSerializer < ActiveModel::Serializer
  attributes :id, :share, :first_name, :last_name
end
