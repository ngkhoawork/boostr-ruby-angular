class RemoveRenderRateFromPmpItemDailyActuals < ActiveRecord::Migration
  def up
    remove_column :pmp_item_daily_actuals, :render_rate
  end

  def down
    add_column :pmp_item_daily_actuals, :render_rate, :decimal
  end
end
