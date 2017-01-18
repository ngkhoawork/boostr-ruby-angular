class Currency < ActiveRecord::Base
  validates :curr_cd, uniqueness: true, length: { is: 3 }, presence: true
  validates :curr_symbol, presence: true
  has_many :exchange_rates
end
