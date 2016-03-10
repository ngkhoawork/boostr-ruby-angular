class AddCol4sToUsers < ActiveRecord::Migration
  def change
    add_column :users, :neg_balance_l_cnt, :integer
    add_column :users, :pos_balance_l_cnt, :integer
  end
end
