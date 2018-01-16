class Dataexport::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_family, :revenue_type, :active, :created, :last_updated

  def product_family
    object.product_family&.name
  end

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end
end
