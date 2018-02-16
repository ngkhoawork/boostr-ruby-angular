class ContentFeeProductBudget < ActiveRecord::Base
  PENDING = 'Pending'.freeze

  belongs_to :content_fee
  delegate :io, to: :content_fee

  scope :for_time_period, -> (start_date, end_date) { where('content_fee_product_budgets.start_date <= ? AND content_fee_product_budgets.end_date >= ?', end_date, start_date) }
  scope :for_year_month, -> (effect_date) { where("DATE_PART('year', start_date) = ? AND DATE_PART('month', start_date) = ?", effect_date.year, effect_date.month) }

  scope :for_product_id, -> (product_id) { where('content_fees.product_id = ?', product_id) if product_id.present? }
  scope :by_seller_id, -> (seller_id) do
    joins(content_fee: { io: :io_members })
    .where(io_members: { user_id: seller_id }) if seller_id.present?
  end
  scope :by_team_id, -> (team_id) do
    joins(content_fee: { io: { io_members: :user } })
      .where(users: { team_id: team_id }) if team_id.present?
  end
  scope :by_created_date, -> (start_date, end_date) do
    where(ios: { created_at: (start_date.to_datetime.beginning_of_day)..(end_date.to_datetime.end_of_day) }) if start_date.present? && end_date.present?
  end

  def daily_budget
    budget.to_f / (end_date - start_date + 1)
  end

  def corrected_daily_budget(io_start_date, io_end_date)
    divider = ([io_end_date, end_date].min.to_date - [io_start_date, start_date].max.to_date + 1)

    divider.zero? ? 0 : budget.to_f / divider
  end

  def update_budget!(budget)
    self.budget = budget
    self.budget_loc = budget / io.exchange_rate
    self.save
  end
end
