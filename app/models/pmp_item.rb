class PmpItem < ActiveRecord::Base
  belongs_to :pmp
  belongs_to :ssp

  has_many :pmp_item_daily_actuals
  has_many :pmp_item_monthly_actuals
end