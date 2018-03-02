class Product::MarginUpdateService
  attr_reader :product, :prev_margin
  
  def initialize(product, prev_margin)
    @product = product
    @prev_margin = prev_margin || 100
  end

  def perform
    costs.each do |cost|
      update_budgets(cost)
    end
  end

  private

  def update_budgets(cost)
    cost.monthly_cost_amounts.each do |monthly_cost_amount|
      budget = monthly_cost_amount.budget / prev_margin * margin
      budget_loc = monthly_cost_amount.budget_loc / prev_margin * margin
      monthly_cost_amount.update(budget: budget, budget_loc: budget_loc)
    end
  end
  
  def costs
    @_costs ||= product.costs.estimated
  end

  def margin
    @_margin ||= product.margin || 100
  end
end
