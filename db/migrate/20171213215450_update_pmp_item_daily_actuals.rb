class UpdatePmpItemDailyActuals < ActiveRecord::Migration
  def up
    change_column :pmp_item_daily_actuals, :bids, :bigint
    change_column :pmp_item_daily_actuals, :impressions, :bigint
    add_column :pmp_item_daily_actuals, :render_rate, :decimal
    add_reference :pmp_item_daily_actuals, :product, index: true, foreign_key: true
  end

  def down
    change_column :pmp_item_daily_actuals, :bids, :decimal
    change_column :pmp_item_daily_actuals, :impressions, :integer
    remove_column :pmp_item_daily_actuals, :render_rate
    remove_reference :pmp_item_daily_actuals, :product
  end
end
