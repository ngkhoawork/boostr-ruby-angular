class CostMonthlyAmount < ActiveRecord::Base
  belongs_to :cost, required: true

  delegate :io, to: :cost

  scope :for_time_period, -> (start_date, end_date) {
    where('cost_monthly_amounts.start_date <= ? AND cost_monthly_amounts.end_date >= ?', end_date, start_date) 
  }

  def daily_budget
    budget.to_f / (end_date - start_date + 1)
  end

  def corrected_daily_budget(io_start_date, io_end_date)
    budget.to_f / ([io_end_date, end_date].min.to_date - [io_start_date, start_date].max.to_date + 1)
  end
end
