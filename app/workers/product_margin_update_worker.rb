class ProductMarginUpdateWorker < BaseWorker
  def perform(product_id, margin, prev_margin)
    product = Product.find(product_id)
    update_budgets(product, margin || 100, prev_margin || 100)
  end

  private

  def update_budgets(product, margin, prev_margin)
    product.costs.estimated.each do |cost|
      update_cost_budget(cost, margin, prev_margin)
    end
  end

  def update_cost_budget(cost, margin, prev_margin)
    cost.cost_monthly_amounts.each do |monthly_cost_amount|
      budget = monthly_cost_amount.budget / prev_margin * margin
      budget_loc = monthly_cost_amount.budget_loc / prev_margin * margin
      monthly_cost_amount.update(budget: budget, budget_loc: budget_loc)
    end
    budget = cost.budget / prev_margin * margin
    budget_loc = cost.budget_loc / prev_margin * margin
    cost.update(budget: budget, budget_loc: budget_loc)
  end
end
