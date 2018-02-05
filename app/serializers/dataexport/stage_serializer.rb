class Dataexport::StageSerializer < ActiveModel::Serializer
  attributes :id, :name, :probability, :open, :active
end
