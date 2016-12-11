class Bp < ActiveRecord::Base
  belongs_to :time_period
  belongs_to :company
  has_many :bp_estimates
  has_many :bp_estimate_products, through: :bp_estimates
end
