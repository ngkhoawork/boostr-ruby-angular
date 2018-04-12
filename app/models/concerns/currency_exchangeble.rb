module CurrencyExchangeble
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    validate :active_exchange_rate
  end

  def exchange_rate
    super || company.exchange_rate_for(currency: self.curr_cd, at_date: (self.created_at || Date.today))
  end

  def active_exchange_rate
    if curr_cd != 'USD'
      unless exchange_rate
        errors.add(
          :curr_cd, "does not have an exchange rate for #{self.curr_cd} at #{(self.created_at || Date.today).strftime('%m/%d/%Y')}"
        )
      end
    end
  end
end
