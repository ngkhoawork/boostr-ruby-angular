class AddMonetoryColumnsToPublisherDailyActuals < ActiveRecord::Migration
  def change
    add_column :publisher_daily_actuals, :total_revenue, :decimal, precision: 10, scale: 2
    add_column :publisher_daily_actuals, :ecpm, :decimal, precision: 10, scale: 2
    add_reference :publisher_daily_actuals, :currency, index: true
  end
end
