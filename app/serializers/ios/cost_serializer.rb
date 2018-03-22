class Ios::CostSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :io_id,
    :product_id,
    :budget,
    :budget_loc,
    :values,
    :created_at,
    :updated_at,
    :product,
    :cost_monthly_amounts
  )

  def cost_monthly_amounts
    object.cost_monthly_amounts.order(start_date: :asc)
  end
end
