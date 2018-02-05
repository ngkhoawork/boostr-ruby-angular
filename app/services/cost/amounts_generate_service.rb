class Cost::AmountsGenerateService
  attr_reader :product, :cost, :io
  
  def initialize(cost)
    @cost = cost
    @product = cost.product
    @io = cost.io
  end

  def perform
    create_cost_monthly_amounts
  end

  private

  def cost_deal_product
    if io && product
      io.deal.deal_products.find_by(product: product)
    else
      nil
    end
  end

  def create_cost_monthly_amounts
    deal_product = cost_deal_product
    if deal_product && deal_product.deal_product_budgets.length == io.months.length
      margin = deal_product.product&.margin || 100
      deal_product.deal_product_budgets.order("start_date asc").each_with_index do |monthly_budget, index|
        budget = monthly_budget.budget * margin / 100.0
        budget_loc = monthly_budget.budget_loc * margin / 100.0
        cost.cost_monthly_amounts.create(
          start_date: monthly_budget.start_date,
          end_date: monthly_budget.end_date,
          budget: budget,
          budget_loc: budget_loc
        )
      end
    else
      generate_cost_monthly_amounts
    end
  end

  def generate_cost_monthly_amounts
    last_index = io.months.count - 1
    total = 0
    total_loc = 0

    io_start_date = io.start_date
    io_end_date = io.end_date
    io.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = cost.budget - total
        monthly_budget_loc = cost.budget_loc - total_loc
      else
        monthly_budget = (cost.daily_budget * io.days_per_month[index]).round(0)
        total += monthly_budget

        monthly_budget_loc = (cost.daily_budget_loc * io.days_per_month[index]).round(0)
        total_loc += monthly_budget_loc
      end

      period = Date.new(*month)
      cost.cost_monthly_amounts.create(
        start_date: [period, io_start_date].max,
        end_date: [period.end_of_month, io_end_date].min,
        budget: monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
  end

  def generate_cost_monthly_amounts
    last_index = io.months.count - 1
    total = 0
    total_loc = 0

    io_start_date = io.start_date
    io_end_date = io.end_date
    io.months.each_with_index do |month, index|
      if last_index == index
        monthly_budget = budget - total
        monthly_budget_loc = budget_loc - total_loc
      else
        monthly_budget = (daily_budget * io.days_per_month[index]).round(0)
        total += monthly_budget

        monthly_budget_loc = (daily_budget_loc * io.days_per_month[index]).round(0)
        total_loc += monthly_budget_loc
      end

      period = Date.new(*month)
      cost_monthly_amounts.create(
        start_date: [period, io_start_date].max,
        end_date: [period.end_of_month, io_end_date].min,
        budget: monthly_budget.round(2),
        budget_loc: monthly_budget_loc.round(2)
      )
    end
  end
end
