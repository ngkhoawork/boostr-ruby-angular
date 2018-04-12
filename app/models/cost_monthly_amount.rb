class CostMonthlyAmount < ActiveRecord::Base
  PENDING = 'Pending'.freeze
  belongs_to :cost

  delegate :io, to: :cost

  scope :for_time_period, -> (start_date, end_date) {
    where('cost_monthly_amounts.start_date <= ? AND cost_monthly_amounts.end_date >= ?', end_date, start_date) 
  }
  scope :for_year_month, -> (effect_date) {
    where(
      "DATE_PART('year', start_date) = ? AND DATE_PART('month', start_date) = ?",
      effect_date.year,
      effect_date.month
    )
  }
  scope :by_oldest, -> { order(:start_date) }

  def daily_budget
    budget.to_f / (end_date - start_date + 1)
  end

  def corrected_daily_budget(io_start_date, io_end_date)
    budget.to_f / ([io_end_date, end_date].min.to_date - [io_start_date, start_date].max.to_date + 1)
  end
end
