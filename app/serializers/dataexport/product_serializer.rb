class Dataexport::ProductSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :name, :product_family_id, :revenue_type, :active, :created, :last_updated
end
