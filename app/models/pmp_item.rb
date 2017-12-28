class PmpItem < ActiveRecord::Base  
  belongs_to :pmp, required: true
  belongs_to :ssp, required: true

  has_many :pmp_item_daily_actuals, -> { order(date: :asc) }, dependent: :destroy
  has_many :pmp_item_monthly_actuals, dependent: :destroy

  enum pmp_type: ::PMP_TYPES

  validates :ssp_deal_id, :budget, :budget_loc, presence: true

  before_validation :convert_currency
  before_save :set_budget_remaining_and_delivered

  after_save do
    update_pmp_budgets if budgets_changed?
    update_revenue_fact if budget_changed? || budget_loc_changed? || pmp_type_changed?
  end

  after_destroy do
    update_pmp_budgets
    update_revenue_fact
  end

  def update_revenue_fact
    Forecast::PmpRevenueCalcTriggerService.new(pmp, 'item', {}).perform
  end

  def self.calculate(ids)
    PmpItem.where(id: ids).find_each do |pmp_item|
      pmp_item.calculate!
    end
  end

  def calculate!
    calculate_budgets!
    calculate_run_rates!
    self.save!
  end

  def calculate_run_rates!
    self.run_rate_7_days = run_rate(7)
    self.run_rate_30_days = run_rate(30)
  end

  def calculate_budgets!
    self.budget_delivered = pmp_item_daily_actuals.sum(:revenue)
    self.budget_delivered_loc = pmp_item_daily_actuals.sum(:revenue_loc)
    self.budget_remaining = [budget - budget_delivered, 0].max
    self.budget_remaining_loc = [budget_loc - budget_delivered_loc, 0].max
  end

  def calculate_end_date!
    daily_actual_end_date = pmp_item_daily_actuals.maximum(:end_date)
    if daily_actual_end_date.present? && end_date < daily_actual_end_date
      self.end_date = daily_actual_end_date
    end
  end

  def run_rate(days)
    if pmp_item_daily_actuals.count >= days
      pmp_item_daily_actuals.latest.limit(days).to_a.sum(&:revenue_loc) / days
    else
      nil
    end
  end

  private

  def convert_currency
    if budget_loc.present? && budget_loc_changed?
      self.budget = budget_loc * pmp.exchange_rate
    end
  end

  def set_budget_remaining_and_delivered
    self.budget_delivered ||= 0
    self.budget_delivered_loc ||= 0
    self.budget_remaining = [budget - budget_delivered, 0].max
    self.budget_remaining_loc = [budget_loc - budget_delivered_loc, 0].max
  end

  def update_pmp_budgets
    pmp.calculate_budgets!
  end

  def budgets_changed?
    budget_loc_changed? || budget_changed? || budget_remaining_changed? || budget_remaining_loc_changed? || budget_delivered_changed? || budget_delivered_loc_changed?
  end
end
