class ContentFeeProductBudget < ActiveRecord::Base
  PENDING = 'Pending'.freeze

  belongs_to :content_fee
  delegate :io, to: :content_fee

  scope :for_time_period, -> (start_date, end_date) { where('content_fee_product_budgets.start_date <= ? AND content_fee_product_budgets.end_date >= ?', end_date, start_date) }

  def daily_budget
    budget.to_f / (end_date - start_date + 1).to_i
  end

  def corrected_daily_budget(io_start_date, io_end_date)
    budget.to_f / ([io_end_date, end_date].min.to_date - [io_start_date, start_date].max.to_date + 1).to_i
  end
end
