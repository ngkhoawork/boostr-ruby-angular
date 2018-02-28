class UpdatePmps < ActiveRecord::Migration
  def up
    remove_column :pmps, '7_day_run_rate'
    remove_column :pmps, '30_day_run_rate'
  end

  def down
    add_column :pmps, '7_day_run_rate', :decimal
    add_column :pmps, '30_day_run_rate', :decimal
  end
end
