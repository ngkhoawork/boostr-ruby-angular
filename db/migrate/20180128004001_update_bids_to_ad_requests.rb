class UpdateBidsToAdRequests < ActiveRecord::Migration
  def up
    add_column :pmp_item_daily_actuals, :ad_requests, :integer
    PmpItemDailyActual.update_all('ad_requests=bids')
    remove_column :pmp_item_daily_actuals, :bids
  end

  def down
    add_column :pmp_item_daily_actuals, :bids, :integer
    PmpItemDailyActual.update_all('bids=ad_requests')
    remove_column :pmp_item_daily_actuals, :ad_requests
  end
end
