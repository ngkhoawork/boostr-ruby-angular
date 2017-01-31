class CreateCurrencyAndExchangeRateTable < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :curr_cd
      t.string :curr_symbol
      t.string :name
    end

    create_table :exchange_rates do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.belongs_to :currency, index: true, foreign_key: true
      t.decimal :rate, precision: 15, scale: 4
    end

    setup_default_currencies
  end

  def setup_default_currencies
    default_currencies = [
      { curr_cd: 'USD', curr_symbol: '$', name: 'United States dollar' },
      { curr_cd: 'EUR', curr_symbol: '€', name: 'Euro' },
      { curr_cd: 'CAD', curr_symbol: '$', name: 'Canadian dollar' },
      { curr_cd: 'GBP', curr_symbol: '£', name: 'Great Britain Pound'},
      { curr_cd: 'AUD', curr_symbol: '$', name: 'Australian dollar'},
      { curr_cd: 'BRL', curr_symbol: 'R$', name: 'Brazilian real'},
      { curr_cd: 'DKK', curr_symbol: 'KR', name: 'Danish krone'},
      { curr_cd: 'CHF', curr_symbol: 'CHF', name: 'Swiss franc'},
      { curr_cd: 'SEK', curr_symbol: 'kr', name: 'Swedish krona'},
      { curr_cd: 'ARS', curr_symbol: '$', name: 'Argentine peso'},
      { curr_cd: 'MXN', curr_symbol: '$', name: 'Mexican peso'},
      { curr_cd: 'JPY', curr_symbol: '¥', name: 'Japanese yen'},
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
