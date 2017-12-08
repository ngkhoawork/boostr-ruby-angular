class PmpItem < ActiveRecord::Base
  belongs_to :pmp, required: true
  belongs_to :ssp, required: true

  has_many :pmp_item_daily_actuals, dependent: :destroy
  has_many :pmp_item_monthly_actuals, dependent: :destroy

  validates :ssp_deal_id, :budget, :budget_loc, presence: true

  before_validation :convert_currency
  before_create :set_budget_remaining_and_delivered
  after_save :update_pmp_budgets, if: :budgets_changed?
  after_destroy :update_pmp_budgets

  private

  def convert_currency
    if self.budget_loc.present? && self.budget_loc_changed?
      self.budget = self.budget_loc * self.pmp.exchange_rate
    end
  end

  def set_budget_remaining_and_delivered
    self.budget_remaining = self.budget
    self.budget_remaining_loc = self.budget_loc
    self.budget_delivered = 0
    self.budget_delivered_loc = 0
  end

  def update_pmp_budgets
    self.pmp.calculate_budgets!
  end

  def budgets_changed?
    budget_loc_changed? || budget_changed? || budget_remaining_changed? || budget_remaining_loc_changed? || budget_delivered_changed? || budget_delivered_loc_changed?
  end
end
