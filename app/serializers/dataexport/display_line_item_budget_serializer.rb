class Dataexport::DisplayLineItemBudgetSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::BudgetFields
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :display_line_item_id, :budget_usd, :budget, :start_date, :end_date, :created,
             :last_updated, :manual_override, :ad_server_budget, :ad_server_quantity, :quantity

  def ad_server_budget
    object.ad_server_budget.to_f
  end
end
