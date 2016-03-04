class AddCol1sToUsers < ActiveRecord::Migration
  def change
    add_column :users, :neg_balance_cnt, :integer
    add_column :users, :pos_balance_cnt, :integer
  end
end
