class RemoveProductFromPmpItemDailyActuals < ActiveRecord::Migration
  def up
    remove_index :pmp_item_daily_actuals, :product_id
    remove_column :pmp_item_daily_actuals, :product_id
  end

  def down
    add_column :pmp_item_daily_actuals, :product_id, :integer
    add_index :pmp_item_daily_actuals, :product_id
  end
end
