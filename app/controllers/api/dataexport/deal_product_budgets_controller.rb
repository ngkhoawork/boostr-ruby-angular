class Api::Dataexport::DealProductBudgetsController < Api::Dataexport::BaseController
  private

  def collection
    DealProductBudget.where(deal_product_id: deal_product_relation.pluck(:id))
  end

  def serializer_class
    ::Dataexport::DealProductBudgetSerializer
  end

  def deal_product_relation
    DealProduct.where(deal_id: current_user.company.deals.pluck(:id))
  end
end
