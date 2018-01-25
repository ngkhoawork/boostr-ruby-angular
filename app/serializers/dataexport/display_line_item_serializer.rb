class Dataexport::DisplayLineItemSerializer < ActiveModel::Serializer
  attributes :id, :io_id, :line_number, :ad_server, :quantity, :budget_usd, :budget, :pricing_type,
             :product_id, :budget_delivered_usd, :budget_remaining_usd, :quantity_delivered,
             :budget_delivered, :budget_remaining, :start_date, :end_date, :price, :ad_server_product,
             :ad_unit, :created, :last_updated

  def budget_usd
    object.budget
  end

  def budget
    object.budget_loc
  end

  def budget_delivered_usd
    object.budget_delivered
  end

  def budget_remaining_usd
    object.budget_remaining
  end

  def quantity_delivered
    object.quantity_delivered
  end

  def budget_delivered
    object.budget_delivered_loc
  end

  def budget_remaining
    object.budget_remaining_loc
  end

  def created
    object.created_at
  end

  def last_updated
    object.updated_at
  end
end
