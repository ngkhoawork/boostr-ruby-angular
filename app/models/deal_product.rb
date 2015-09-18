class DealProduct < ActiveRecord::Base
  belongs_to :deal
  belongs_to :product

  before_update do
    self.budget = budget * 100 if budget_changed?
  end

  after_update do
    deal.update_total_budget
  end

  def start_date
    period
  end

  def end_date
    period.end_of_month
  end

  def daily_budget
    (budget / 100.0) / (end_date - start_date + 1).to_i
  end
end
