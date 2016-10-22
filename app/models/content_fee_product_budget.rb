class ContentFeeProductBudget < ActiveRecord::Base
  belongs_to :content_fee

  scope :for_time_period, -> (start_date, end_date) { where('content_fee_product_budgets.start_date <= ? AND content_fee_product_budgets.end_date >= ?', end_date, start_date) }

  def daily_budget
    budget.to_f / (end_date - start_date + 1).to_i
  end
end
