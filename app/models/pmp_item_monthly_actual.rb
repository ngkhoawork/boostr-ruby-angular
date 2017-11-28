class PmpItemMonthlyActual < ActiveRecord::Base
  belongs_to :pmp_item, required: true

  validates :amount, :amount_loc, presence: true
end