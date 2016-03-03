class AddColsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :neg_balance, :integer
    add_column :users, :pos_balance, :integer
    add_column :users, :last_alert_at, :datetime
  end
end
