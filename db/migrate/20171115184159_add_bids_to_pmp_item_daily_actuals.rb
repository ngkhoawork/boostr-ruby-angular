class AddBidsToPmpItemDailyActuals < ActiveRecord::Migration
  def change
    add_column :pmp_item_daily_actuals, :bids, :decimal, precision: 15, scale: 2
  end
end
