module CurrencyExchangeble
  extend ActiveSupport::Concern
  include ActiveModel::Validations

  included do
    validate :active_exchange_rate
  end

  def exchange_rate
    company.exchange_rate_for(currency: self.curr_cd, at_date: (self.created_at || Date.today))
  end

  def convert_to_usd(value)
    if exchange_rate_at_close
      value.to_f * exchange_rate_at_close
    else
      value.to_f / exchange_rate
    end
  end

  def active_exchange_rate
    if curr_cd != 'USD'
      unless exchange_rate_at_close || exchange_rate
        errors.add(
          :curr_cd, "does not have an exchange rate for #{self.curr_cd} at #{(self.created_at || Date.today).strftime('%m/%d/%Y')}"
        )
      end
    end
  end
end
