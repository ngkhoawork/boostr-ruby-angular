class DealProductBudgetPipelineService < BaseService

  def weighted_amount
   (budget * probability / 100).to_f
  end

  def unweighted_amount
    budget
  end

  private

  def probability
    deal_product_budget.probability.present? ? deal_product_budget.probability : 0
  end

  def budget
    deal_product_budget.budget.present? ? deal_product_budget.budget : 0
  end

end