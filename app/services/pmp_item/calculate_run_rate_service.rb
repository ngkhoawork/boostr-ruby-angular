class PmpItem::CalculateRunRateService < BaseWorker
  attr_reader :company, :pmp_item_ids
  
  def initialize(company, pmp_item_ids)
    @company = company
    @pmp_item_ids = pmp_item_ids
  end

  def perform
    pmp_items.find_each do |pmp_item|
      calculate_run_rate(pmp_item)
    end
  end

  private

  def calculate_run_rate(pmp_item)
    pmp_item_actuals_7_days = pmp_item.pmp_item_daily_actuals.latest.limit(7)
    run_rate_7_days = pmp_item_actuals_7_days.sum(:revenue) / pmp_item_actuals_7_days.count

    pmp_item_actuals_30_days = pmp_item.pmp_item_daily_actuals.latest.limit(30)
    run_rate_30_days = pmp_item_actuals_30_days.sum(:revenue) / pmp_item_actuals_30_days.count

    pmp_item.update(run_rate_7_days: run_rate_7_days, run_rate_30_days: run_rate_30_days)
  end

  def pmp_items
    @_pmp_items ||= PmpItem.where(id: pmp_item_ids)
  end
end
