class DealProduct::ResetBudgetsService
  def initialize(deal_product)
    @deal_product = deal_product
    @deal         = deal_product.deal
    @total        = 0
    @total_loc    = 0
  end

  def perform
    deal_product_budgets.destroy_all
    generate_all_product_budgets
  end

  attr_reader :deal,
              :deal_product

  attr_accessor :total,
                :total_loc

  private
  def generate_all_product_budgets
    months.each_with_index do |month, index|
      budget, budget_loc = get_monthly_budgets(month, index)
      create_product_budget(month, budget, budget_loc)
    end
  end

  def get_monthly_budgets(month, index)
    if last_index == index
      get_monthly_last_budgets
    else
      get_monthly_auto_budgets(index)
    end
  end

  def get_monthly_last_budgets
    budget = deal_product.budget - total
    budget_loc = deal_product.budget_loc - total_loc

    return budget, budget_loc
  end

  def get_monthly_auto_budgets(index)
    budget = (deal_product.daily_budget * deal.days_per_month[index]).round(0)
    budget = 0 if budget.between?(0, 1)
    self.total += budget

    budget_loc = (deal_product.daily_budget_loc * deal.days_per_month[index]).round(0)
    budget_loc = 0 if budget_loc.between?(0, 1)
    self.total_loc += budget_loc

    return budget, budget_loc
  end

  def create_product_budget(month, budget, budget_loc)
    period = Date.new(*month)
    deal_product_budgets.create(
      start_date: [period, start_date].max,
      end_date: [period.end_of_month, end_date].min,
      budget: budget,
      budget_loc: budget_loc
    )
  end

  def start_date
    deal.start_date
  end

  def end_date
    deal.end_date
  end

  def last_index
    @_last_index = months.count - 1
  end

  def months
    @_months ||= deal.months
  end

  def deal_product_budgets
    deal_product.deal_product_budgets.by_oldest
  end
end
