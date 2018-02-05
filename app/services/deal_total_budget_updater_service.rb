class DealTotalBudgetUpdaterService
  attr_reader :deal

  def self.perform(*args)
    new(*args).perform
  end

  def initialize(deal)
    @deal = deal
  end

  def perform
    deal.log_budget_changes(current_budget, new_budget)
    deal.assign_attributes(budget: new_budget, budget_loc: new_budget_loc)
    deal.save(validate: false)
  end

  private

  def current_budget
    deal.budget.nil? ? 0 : deal.budget
  end

  def new_budget
    @_new_budget ||= deal.deal_product_budgets.sum(:budget)
  end

  def new_budget_loc
    deal.deal_product_budgets.sum(:budget_loc)
  end
end
