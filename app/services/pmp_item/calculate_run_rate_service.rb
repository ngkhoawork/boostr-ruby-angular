class PmpItem::CalculateRunRateService < BaseWorker
  attr_reader :company, :pmp_item_ids
  
  def initialize(company, pmp_item_ids)
    @company = company
    @pmp_item_ids = pmp_item_ids
  end

  def perform
    pmp_items.find_each do |pmp_item|
      calculate_run_rate_and_budgets(pmp_item)
    end
  end

  private

  def calculate_run_rate_and_budgets(pmp_item)
    pmp_item_actuals = pmp_item.pmp_item_daily_actuals.latest.limit(30).to_a
    if pmp_item_actuals.count >= 7
      run_rate_7_days = pmp_item_actuals.first(7).map(&:revenue).inject(0, &:+) / 7
    else
      run_rate_7_days = nil
    end
    if pmp_item_actuals.count >=30
      run_rate_30_days = pmp_item_actuals.map(&:revenue).inject(0, &:+) / 30
    else
      run_rate_30_days = nil
    end

    budget_delivered = pmp_item.pmp_item_daily_actuals.sum(:revenue)
    budget_delivered_loc = pmp_item.pmp_item_daily_actuals.sum(:revenue_loc)
    budget_remaining = [pmp_item.budget - budget_delivered, 0].max
    budget_remaining_loc = [pmp_item.budget_loc - budget_delivered_loc, 0].max

    pmp_item.update(run_rate_7_days: run_rate_7_days, 
      run_rate_30_days: run_rate_30_days,
      budget_delivered: budget_delivered,
      budget_delivered_loc: budget_delivered_loc,
      budget_remaining: budget_remaining,
      budget_remaining_loc: budget_remaining_loc)
  end

  def pmp_items
    @_pmp_items ||= PmpItem.where(id: pmp_item_ids)
  end
end
