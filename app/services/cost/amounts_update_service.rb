class Cost::AmountsUpdateService
  attr_reader :cost_monthly_amounts, :cost, :io
  
  def initialize(cost)
    @cost = cost
    @cost_monthly_amounts = cost.cost_monthly_amounts
    @io = cost.io
  end

  def perform
    update_cost_monthly_amounts
  end

  private

  def update_cost_monthly_amounts
    last_index = cost_monthly_amounts.count - 1
    total, total_loc = 0, 0

    cost_monthly_amounts.order("start_date asc").each_with_index do |cost_monthly_amount, index|
      if last_index == index
        monthly_budget = (cost.budget) - total
        monthly_budget_loc = cost.budget_loc - total_loc
      else
        monthly_budget = (cost.daily_budget * io.days_per_month[index]).round(2)
        monthly_budget_loc = (cost.daily_budget_loc * io.days_per_month[index]).round(2)
        total += monthly_budget
        total_loc += monthly_budget_loc
      end
      cost_monthly_amount.update(
        budget: monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
  end
end
