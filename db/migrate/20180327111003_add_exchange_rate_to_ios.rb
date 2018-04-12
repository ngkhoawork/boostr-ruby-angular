class AddExchangeRateToIos < ActiveRecord::Migration
  def change
    unless column_exists? :ios, :exchange_rate
      add_column :ios, :exchange_rate, :float
    end
  end
end
