class AddRunRatesToPmpItems < ActiveRecord::Migration
  def change
    add_column :pmp_items, :run_rate_7_days, :decimal, precision: 15, scale: 2, default: 0
    add_column :pmp_items, :run_rate_30_days, :decimal, precision: 15, scale: 2, default: 0
  end
end
