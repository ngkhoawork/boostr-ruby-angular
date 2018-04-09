class ContentFee::ResetBudgetsService
  def initialize(content_fee)
    @content_fee  = content_fee
    @io           = content_fee.io
  end

  def perform
    content_fee_product_budgets.destroy_all
    generate_all_product_budgets
  end

  private

  attr_reader :io,
              :content_fee

  def generate_all_product_budgets
    last_index  = io.months.count - 1
    total       = 0
    total_loc   = 0
    
    io.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget      = content_fee.budget.to_f - total
        monthly_budget_loc  = content_fee.budget_loc.to_f - total_loc
      else
        monthly_budget      = (content_fee.daily_budget * io.days_per_month[index]).round(0)
        monthly_budget_loc  = (content_fee.daily_budget_loc * io.days_per_month[index]).round(0)
        total               += monthly_budget
        total_loc           += monthly_budget_loc
      end
      period = Date.new(*month)
      content_fee_product_budgets.create(
        start_date: [period, io.start_date].max,
        end_date:   [period.end_of_month, io.end_date].min,
        budget:     monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
  end

  def content_fee_product_budgets
    content_fee.content_fee_product_budgets.by_oldest
  end
end
