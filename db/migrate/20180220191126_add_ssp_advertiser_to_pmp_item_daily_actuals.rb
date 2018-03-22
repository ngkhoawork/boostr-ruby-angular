class AddSspAdvertiserToPmpItemDailyActuals < ActiveRecord::Migration
  def change
    add_reference :pmp_item_daily_actuals, :ssp_advertiser, index: true, foreign_key: true
    add_column :pmp_item_daily_actuals, :advertiser, :string
  end
end
