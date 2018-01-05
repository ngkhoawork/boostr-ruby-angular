class Api::Publishers::StageSerializer < ActiveModel::Serializer
  attributes :id, :name, :probability
end
