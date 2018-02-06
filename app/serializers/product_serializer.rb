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
    :option1_id,
    :option1,
    :option2_id,
    :option2
  )

  def product_family
    object.product_family.serializable_hash(only: [:id, :name]) rescue nil
  end

  def option1
    object.option1.serializable_hash(only: [:id, :name]) rescue nil
  end

  def option2
    object.option2.serializable_hash(only: [:id, :name]) rescue nil
  end
end
