class Cost::AmountsGenerateService
  attr_reader :product, :cost, :io
  
  def initialize(cost)
    @cost = cost
    @product = cost.product
    @io = cost.io
  end

  def perform
    generate_cost_amounts
  end

  private

  def deal_product
    if io && product
      io.deal.deal_products.find_by(product: product)
    else
      nil
    end
  end

  def generate_cost_amounts
    if cost.imported
      generate_empty_amounts
    else
      generate_auto_amounts
    end
  end

  def generate_empty_amounts
    io.months.each_with_index do |month, index|
      period = Date.new(*month)
      cost.cost_monthly_amounts.create(
        start_date: [period, io.start_date].max,
        end_date: [period.end_of_month, io.end_date].min,
        budget: 0,
        budget_loc: 0
      )
    end
  end

  def generate_from_deal_products
    margin = deal_product.product&.margin || 100
    deal_product.deal_product_budgets.order("start_date asc").each_with_index do |monthly_budget, index|
      budget = monthly_budget.budget * (100 - margin) / 100.0
      budget_loc = monthly_budget.budget_loc * (100 - margin) / 100.0
      cost.cost_monthly_amounts.create(
        start_date: monthly_budget.start_date,
        end_date: monthly_budget.end_date,
        budget: budget,
        budget_loc: budget_loc
      )
    end
  end

  def generate_auto_amounts
    last_index = io.months.count - 1
    total, total_loc = 0, 0

    io.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = cost.budget - total
        monthly_budget_loc = cost.budget_loc - total_loc
      else
        monthly_budget = (cost.daily_budget * io.days_per_month[index]).round(0)
        monthly_budget_loc = (cost.daily_budget_loc * io.days_per_month[index]).round(0)
        total += monthly_budget
        total_loc += monthly_budget_loc
      end

      period = Date.new(*month)
      cost.cost_monthly_amounts.create(
        start_date: [period, io.start_date].max,
        end_date: [period.end_of_month, io.end_date].min,
        budget: monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
  end
end
