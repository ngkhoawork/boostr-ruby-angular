class BillingSummary::CostSerializer < ActiveModel::Serializer
  attributes :id, :product, :io_id, :values

  def product
    object.product.name
  end

  def values
    object.values
  end
end
