class PmpItem < ActiveRecord::Base
  belongs_to :pmp, required: true
  belongs_to :ssp, required: true

  has_many :pmp_item_daily_actuals, dependent: :destroy
  has_many :pmp_item_monthly_actuals, dependent: :destroy

  validates :ssp_deal_id, :budget, :budget_loc, presence: true

  before_validation :convert_currency, on: :create
  before_create :set_budget_remaining_and_delivered

  private

  def convert_currency
    if self.budget.nil? && self.budget_loc.present?
      self.budget = self.budget_loc * self.pmp.exchange_rate
    end
  end

  def set_budget_remaining_and_delivered
    self.budget_remaining = self.budget
    self.budget_remaining_loc = self.budget_loc
    self.budget_delivered = 0
    self.budget_delivered_loc = 0
  end
end
