class DisplayLineItem::UpdateBudgetDelivered
  def initialize(budget_item)
    @object = budget_item.display_line_item
  end

  def perform
    return unless budget_delivered_changed?
    object.update_columns(
      budget_delivered:     budget_delivered,
      budget_delivered_loc: budget_delivered_loc,
      budget_remaining:     budget_remaining,
      budget_remaining_loc: budget_remaining_loc
    )
  end

  private

  attr_reader :object

  def budget_delivered_changed?
    object.budget_delivered.to_f != budget_delivered.to_f
  end

  def display_line_item_budgets
    @_display_line_item_budgets ||= object.display_line_item_budgets
  end

  def budget_delivered
    @_budget_delivered ||= display_line_item_budgets.sum(:budget) || 0
  end

  def budget_delivered_loc
    @_budget_delivered_loc ||= display_line_item_budgets.sum(:budget_loc) || 0
  end

  def budget_remaining
    [(object.budget || 0) - budget_delivered, 0].max
  end

  def budget_remaining_loc
    [(object.budget_loc || 0) - budget_delivered_loc, 0].max
  end
end
