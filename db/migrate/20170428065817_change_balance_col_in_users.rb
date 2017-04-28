class ChangeBalanceColInUsers < ActiveRecord::Migration
  def up
    change_column :users, :neg_balance, :integer, limit: 8
    change_column :users, :neg_balance_cnt, :integer, limit: 8
    change_column :users, :pos_balance_cnt, :integer, limit: 8
    change_column :users, :neg_balance_lcnt, :integer, limit: 8
    change_column :users, :pos_balance_lcnt, :integer, limit: 8
    change_column :users, :neg_balance_l, :integer, limit: 8
    change_column :users, :pos_balance_l, :integer, limit: 8
    change_column :users, :neg_balance_l_cnt, :integer, limit: 8
    change_column :users, :pos_balance_l_cnt, :integer, limit: 8
  end

  def down
    change_column :users, :neg_balance, :integer
    change_column :users, :neg_balance_cnt, :integer
    change_column :users, :pos_balance_cnt, :integer
    change_column :users, :neg_balance_lcnt, :integer
    change_column :users, :pos_balance_lcnt, :integer
    change_column :users, :neg_balance_l, :integer
    change_column :users, :pos_balance_l, :integer
    change_column :users, :neg_balance_l_cnt, :integer
    change_column :users, :pos_balance_l_cnt, :integer
  end
end
