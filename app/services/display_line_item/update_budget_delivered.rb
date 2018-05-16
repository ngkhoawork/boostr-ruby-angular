class DisplayLineItem::UpdateBudgetDelivered
  def initialize(display_item)
    @item = display_item
  end

  def perform
    return if nothing_to_change?
    item.update(
      budget_delivered:     budget_delivered,
      budget_delivered_loc: budget_delivered_loc,
      budget_remaining:     budget_remaining,
      budget_remaining_loc: budget_remaining_loc,
      override_budget_delivered: true
    )
  end

  private

  attr_reader :item

  def nothing_to_change?
    item.budget_delivered.to_f == budget_delivered.to_f &&
      item.budget_delivered_loc.to_f == budget_delivered_loc.to_f &&
      item.budget_remaining.to_f == budget_remaining.to_f &&
      item.budget_remaining_loc.to_f == budget_remaining_loc.to_f
  end

  def display_line_item_budgets
    @_display_line_item_budgets ||= item.display_line_item_budgets
  end

  def budget_delivered
    @_budget_delivered ||= display_line_item_budgets.sum(:budget) || 0
  end

  def budget_delivered_loc
    @_budget_delivered_loc ||= display_line_item_budgets.sum(:budget_loc) || 0
  end

  def budget_remaining
    @_budget_remaining ||= [(item.budget || 0) - budget_delivered, 0].max
  end

  def budget_remaining_loc
    @_budget_remaining_loc ||= [(item.budget_loc || 0) - budget_delivered_loc, 0].max
  end
end
