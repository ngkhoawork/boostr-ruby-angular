class ContentFee::UpdateBudgetsService
  def initialize(content_fee)
    @content_fee      = content_fee
    @io               = content_fee.io
  end

  def perform
    update_budgets
  end

  private

  attr_reader :io,
              :content_fee

  def update_budgets
    total, total_loc = 0.0, 0.0

    content_fee_product_budgets.each.with_index do |content_fee_product_budget, index|
      if last_index == index
        monthly_budget = content_fee.budget - total
        monthly_budget_loc = content_fee.budget_loc - total_loc
      else
        monthly_budget = (content_fee.daily_budget * io.days_per_month[index]).round(2)
        total += monthly_budget

        monthly_budget_loc = (content_fee.daily_budget_loc * io.days_per_month[index]).round(2)
        total_loc += monthly_budget_loc
      end
      content_fee_product_budget.update(
        budget: monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
  end

  def last_index
    @_last_index ||= content_fee_product_budgets.count - 1
  end

  def content_fee_product_budgets
    content_fee.content_fee_product_budgets.by_oldest
  end
end
