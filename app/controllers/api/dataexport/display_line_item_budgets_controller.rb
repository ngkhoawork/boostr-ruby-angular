class Api::Dataexport::DisplayLineItemBudgetsController < Api::Dataexport::BaseController
  private

  def collection
    DisplayLineItemBudget.where(display_line_item_id: display_line_items_relation.pluck(:id))
  end

  def serializer_class
    ::Dataexport::DisplayLineItemBudgetSerializer
  end

  def display_line_items_relation
    DisplayLineItem.where(io_id: current_user.company.ios.pluck(:id))
  end
end
