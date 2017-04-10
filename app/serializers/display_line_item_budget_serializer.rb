class DisplayLineItemBudgetSerializer < ActiveModel::Serializer
  attributes :id, :budget, :month

  def month
    object.start_date.strftime('%b %Y')
  end
end
