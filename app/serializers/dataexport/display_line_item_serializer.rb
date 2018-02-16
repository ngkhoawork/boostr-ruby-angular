class Dataexport::DisplayLineItemSerializer < ActiveModel::Serializer
  include Dataexport::CommonFields::BudgetFields
  include Dataexport::CommonFields::TimestampFields

  attributes :id, :io_id, :line_number, :ad_server, :quantity, :budget_usd, :budget, :pricing_type,
             :product_id, :budget_delivered_usd, :budget_remaining_usd, :quantity_delivered,
             :budget_delivered, :budget_remaining, :start_date, :end_date, :price, :ad_server_product,
             :ad_unit, :created, :last_updated

  def budget_delivered_usd
    object.budget_delivered.to_f
  end

  def budget_remaining_usd
    object.budget_remaining.to_f
  end

  def quantity_delivered
    object.quantity_delivered
  end

  def budget_delivered
    object.budget_delivered_loc.to_f
  end

  def budget_remaining
    object.budget_remaining_loc.to_f
  end
end
