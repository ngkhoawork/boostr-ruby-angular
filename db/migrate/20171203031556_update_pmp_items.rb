class UpdatePmpItems < ActiveRecord::Migration
  def up
    change_column :pmp_items, :run_rate_7_days, :decimal, default: nil
    change_column :pmp_items, :run_rate_30_days, :decimal, default: nil
  end

  def down
    change_column :pmp_items, :run_rate_7_days, :decimal, default: 0
    change_column :pmp_items, :run_rate_30_days, :decimal, default: 0
  end
end
