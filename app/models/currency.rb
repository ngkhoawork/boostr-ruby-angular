class Currency < ActiveRecord::Base
  validates :curr_cd, uniqueness: true, length: { is: 3 }, presence: true
  validates :curr_symbol, presence: true

  has_many :exchange_rates

  scope :with_exchange_rates_for, -> (company_id) { includes(:exchange_rates).
                                                    where(exchange_rates: {company_id: company_id}) }
end
