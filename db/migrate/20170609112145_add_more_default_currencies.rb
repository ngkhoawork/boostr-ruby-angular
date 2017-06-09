class AddMoreDefaultCurrencies < ActiveRecord::Migration
  def change
    add_default_currencies
  end

  def add_default_currencies
    default_currencies = [
      { curr_cd: 'MYR', curr_symbol: 'RM', name: 'Malaysian Ringgit' },
      { curr_cd: 'SGD', curr_symbol: '$', name: 'Singapore Dollar' },
      { curr_cd: 'NZD', curr_symbol: '$', name: 'New Zealand Dollar' },
      { curr_cd: 'PHP', curr_symbol: '₱', name: 'Philippine Peso'},
    ]

    default_currencies.each do |currency|
      Currency.create(
        name: currency[:name],
        curr_cd: currency[:curr_cd],
        curr_symbol: currency[:curr_symbol]
      )
    end
  end
end
