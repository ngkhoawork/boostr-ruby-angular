class DisplayLineItemBudgetSerializer < ActiveModel::Serializer
  attributes :id, :budget, :budget_loc, :month

  def month
    object.start_date.strftime('%b %Y')
  end

  def budget_loc
    object.budget_loc.to_i
  end
end
