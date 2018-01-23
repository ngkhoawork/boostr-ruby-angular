class DealTotalBudgetUpdaterService
  attr_reader :deal

  def self.call(*args)
    new(*args).call
  end

  def initialize(deal)
    @deal = deal
  end

  def call
    current_budget = deal.budget.nil? ? 0 : deal.budget
    new_budget = deal.deal_product_budgets.sum(:budget)
    new_budget_loc = deal.deal_product_budgets.sum(:budget_loc)

    deal.log_budget_changes(current_budget, new_budget)

    deal.assign_attributes(budget: new_budget, budget_loc: new_budget_loc)

    if deal.save(validate: false)
      GoogleSheetsWorker.perform_async(google_sheet_id, deal.id) if google_sheet_id
    end
  end

  private

  def google_sheet_id
    @_google_sheet_id ||= deal.company.google_sheets_configurations.first&.sheet_id
  end
end
