class AddRupeeCurrency < ActiveRecord::Migration
  def change
    add_new_currency
  end

  def add_new_currency
    new_currency = { curr_cd: 'INR', curr_symbol: '₹', name: 'Indian rupee' }

    Currency.create(
      name: new_currency[:name],
      curr_cd: new_currency[:curr_cd],
      curr_symbol: new_currency[:curr_symbol]
    )
  end
end
