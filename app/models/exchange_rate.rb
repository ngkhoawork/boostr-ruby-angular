class ExchangeRate < ActiveRecord::Base
  belongs_to :company
  belongs_to :currency

  validates :rate, presence: true
end
