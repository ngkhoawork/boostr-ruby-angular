class Teams::BaseSerializer < ActiveModel::Serializer
  attributes :id, :name, :leader_id, :parent_id
end
