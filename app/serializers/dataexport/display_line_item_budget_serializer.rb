class Dataexport::DisplayLineItemBudgetSerializer < ActiveModel::Serializer
  attributes :id, :display_line_item_id, :budget_usd, :budget, :start_date, :end_date, :created,
             :last_updated, :manual_override, :ad_server_budget, :ad_server_quantity, :quantity

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
