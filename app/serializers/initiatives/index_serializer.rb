class Initiatives::IndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :goal, :status
end
