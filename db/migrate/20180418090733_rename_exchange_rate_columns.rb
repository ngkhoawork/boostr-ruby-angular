class RenameExchangeRateColumns < ActiveRecord::Migration
  def change
    rename_column :ios, :exchange_rate, :exchange_rate_at_close
    rename_column :temp_ios, :exchange_rate, :exchange_rate_at_close

    change_column :ios, :exchange_rate_at_close, :decimal, precision: 10, scale: 4
    change_column :temp_ios, :exchange_rate_at_close, :decimal, precision: 10, scale: 4
  end
end
