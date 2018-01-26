class Dataexport::ProductSerializer < ActiveModel::Serializer
  attributes :id, :name, :product_family_id, :revenue_type, :active, :created, :last_updated

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end
end
