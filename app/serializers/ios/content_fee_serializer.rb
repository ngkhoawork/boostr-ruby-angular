class Ios::ContentFeeSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :io_id,
    :product_id,
    :budget,
    :created_at,
    :updated_at,
    :budget_loc,
    :product,
    :content_fee_product_budgets
  )

  def content_fee_product_budgets
    object.content_fee_product_budgets.order(start_date: :asc)
  end
end
