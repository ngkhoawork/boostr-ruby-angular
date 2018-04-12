class AddExchangeRateToTempIos < ActiveRecord::Migration
  def change
    unless column_exists? :temp_ios, :exchange_rate
      add_column :temp_ios, :exchange_rate, :float
    end
  end
end
