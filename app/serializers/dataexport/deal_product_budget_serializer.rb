class Dataexport::DealProductBudgetSerializer < ActiveModel::Serializer
  attributes :deal_product_id, :start_date, :end_date, :budget_usd, :budget

  def budget_usd
    object.budget
  end

  def budget
    object.budget_loc
  end
end
