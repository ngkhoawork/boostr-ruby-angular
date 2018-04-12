class AddMd5SignatureToPmpItemDailyActuals < ActiveRecord::Migration
  def change
    unless column_exists? :pmp_item_daily_actuals, :md5_signature
      add_column :pmp_item_daily_actuals, :md5_signature, :string, unique: true
      add_timestamps :pmp_item_daily_actuals
      add_index :pmp_item_daily_actuals, :md5_signature, unique: true
    end
  end
end
