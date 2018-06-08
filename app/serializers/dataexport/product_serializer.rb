class Dataexport::ProductSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :name, :product_family_id, :revenue_type, :active, :created, :last_updated, :full_name, :parent_product_id

  def parent_product_id
    object.parent_id
  end
end
