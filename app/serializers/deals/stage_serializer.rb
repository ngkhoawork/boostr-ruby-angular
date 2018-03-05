class Deals::StageSerializer < ActiveModel::Serializer
  attributes :id, :probability, :open, :active
end
