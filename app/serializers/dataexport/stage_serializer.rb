class Dataexport::StageSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :name, :probability, :open, :active, :created, :last_updated
end
