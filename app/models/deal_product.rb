class DealProduct < ActiveRecord::Base
  belongs_to :deal, touch: true
  belongs_to :product

  scope :for_time_period, -> (start_date, end_date) { where('deal_products.start_date <= ? AND deal_products.end_date >= ?', end_date, start_date) }

  validates :start_date, :end_date, presence: true

  before_update do
    self.budget = budget * 100 if budget_changed?
  end

  after_update do
    deal.update_total_budget
  end

  def daily_budget
    (budget / 100.0) / (end_date - start_date + 1).to_i
  end
end
