class ChangeFillRateDataTypeForPublisherDailyActual < ActiveRecord::Migration
  def up
    change_column :publisher_daily_actuals, :fill_rate, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :publisher_daily_actuals, :fill_rate, :integer
  end
end
