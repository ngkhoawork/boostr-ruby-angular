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
    :margin,
    :level,
    :parent_id,
    :parent,
    :top_parent_id,
    :top_parent,
    :full_name,
    :level0,
    :level1,
    :level2
  )

  def product_family
    object.product_family.serializable_hash(only: [:id, :name]) rescue nil
  end

  def parent
    object.parent.serializable_hash(only: [:id, :name]) rescue nil
  end

  def top_parent
    object.top_parent.serializable_hash(only: [:id, :name]) rescue nil
  end
end
