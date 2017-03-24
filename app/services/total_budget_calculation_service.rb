class TotalBudgetCalculationService

  def initialize(client)
    @client = client
  end

  def perform
    calculate_total_budgets
  end

  private

  attr_reader :client

  def calculate_total_budgets
    deal_product_budgets.each_with_object({}) do |deal_product_budget, total_budgets|
      time_dimensions.each do |time_dimension|
        if time_dimension.start_date <= deal_product_budget.end_date && deal_product_budget.end_date >= deal_product_budget.start_date
          if total_budgets[time_dimension.id].nil?
            total_budgets[time_dimension.id] = 0
          end
          total_budgets[time_dimension.id] = total_budgets[time_dimension.id] + tot_budget_by_time_dim(deal_product_budget, time_dimension)
        end
      end
    end
  end

  def tot_budget_by_time_dim(deal_prod_bud, time_dim)
    daily_budget = calculate_daily_budget(deal_prod_bud)
    probability = calculate_probability(deal_prod_bud)
    from = [time_dim.start_date.to_date, deal_prod_bud.start_date.to_date].max
    to = [time_dim.end_date.to_date, deal_prod_bud.end_date.to_date].min
    days = [(to - from) + 1, 0].max
    daily_budget * days * (probability / 100.0)
  end

  def calculate_daily_budget(deal_product_budget)
    (deal_product_budget.budget.present? ? deal_product_budget.budget : 0) / (deal_product_budget.end_date.to_date - deal_product_budget.start_date.to_date + 1).to_f
  end

  def calculate_probability(deal_product_budget)
    deal_product_budget.stage_prob.present? ? deal_product_budget.stage_prob : 0
  end

  def time_dimensions
    @time_dimenstions ||= TimeDimension.all
  end

  def deal_product_budgets
    @dp_budgets ||= DpBudgetQuery.new(client_id: client.id, company_id: client.company_id).all
  end
end