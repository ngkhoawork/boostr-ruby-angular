class PmpItem < ActiveRecord::Base
  belongs_to :pmp, required: true
  belongs_to :ssp, required: true

  has_many :pmp_item_daily_actuals, dependent: :destroy
  has_many :pmp_item_monthly_actuals, dependent: :destroy

  validates :ssp_deal_id, :budget, :budget_loc, presence: true
end
