class Dataexport::DealProductBudgetSerializer < ActiveModel::Serializer
  attributes :deal_product_id, :start_date, :end_date, :budget_usd, :budget, :created, :last_updated

  def budget_usd
    object.budget
  end

  def budget
    object.budget_loc
  end

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end
end
