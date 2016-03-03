class AddColsToRevenues < ActiveRecord::Migration
  def change
    add_column :revenues, :run_rate, :integer
    add_column :revenues, :remaining_day, :integer
    add_column :revenues, :balance, :integer
    add_column :revenues, :last_alert_at, :datetime
  end
end
