class DisplayLineItemBudgetSerializer < ActiveModel::Serializer
  attributes :id, :display_line_item_id, :budget_loc, :month

  def month
    object.start_date.strftime('%b %Y')
  end

  def budget_loc
    object.budget_loc.to_i
  end

  def display_line_item_id
    object.display_line_item.id
  end
end
