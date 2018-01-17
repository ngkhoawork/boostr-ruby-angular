class ProductSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :name,
    :product_family_id,
    :product_family,
    :revenue_type,
    :active,
    :values,
    :is_influencer_product,
    :margin
  )

  def product_family
    object.product_family.serializable_hash(only: [:id, :name]) rescue nil
  end
end
