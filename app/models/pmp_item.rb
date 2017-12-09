class PmpItem < ActiveRecord::Base  
  belongs_to :pmp, required: true
  belongs_to :ssp, required: true

  has_many :pmp_item_daily_actuals, dependent: :destroy
  has_many :pmp_item_monthly_actuals, dependent: :destroy

  validates :ssp_deal_id, :budget, :budget_loc, presence: true

  before_validation :convert_currency
  before_save :set_budget_remaining_and_delivered
  after_save :update_pmp_budgets, if: :budgets_changed?
  after_destroy :update_pmp_budgets

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
    self.budget_remaining = [self.budget - self.budget_delivered, 0].max
    self.budget_remaining_loc = [self.budget_loc - self.budget_delivered_loc, 0].max
  end

  def run_rate(days)
    if pmp_item_daily_actuals.count >= days
      pmp_item_daily_actuals.latest.limit(days).sum(:revenue_loc) / days
    else
      nil
    end
  end

  private

  def convert_currency
    if self.budget_loc.present? && self.budget_loc_changed?
      self.budget = self.budget_loc * self.pmp.exchange_rate
    end
  end

  def set_budget_remaining_and_delivered
    self.budget_delivered ||= 0
    self.budget_delivered_loc ||= 0
    self.budget_remaining = self.budget - self.budget_delivered
    self.budget_remaining_loc = self.budget_loc - self.budget_delivered_loc
  end

  def update_pmp_budgets
    self.pmp.calculate_budgets!
  end

  def budgets_changed?
    budget_loc_changed? || budget_changed? || budget_remaining_changed? || budget_remaining_loc_changed? || budget_delivered_changed? || budget_delivered_loc_changed?
  end
end
