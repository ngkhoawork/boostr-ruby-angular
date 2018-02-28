class AddClientToPmpItemDailyActuals < ActiveRecord::Migration
  def up
    rename_column :pmp_item_daily_actuals, :advertiser, :ssp_advertiser
    remove_reference :pmp_item_daily_actuals, :ssp_advertiser, index: true, foreign_key: true
    add_column :pmp_item_daily_actuals, :advertiser_id, :integer
    add_index :pmp_item_daily_actuals, :advertiser_id
  end

  def down
    rename_column :pmp_item_daily_actuals, :ssp_advertiser, :advertiser
    add_reference :pmp_item_daily_actuals, :ssp_advertiser, index: true, foreign_key: true
    remove_index :pmp_item_daily_actuals, :advertiser_id
    remove_column :pmp_item_daily_actuals, :advertiser_id
  end
end
