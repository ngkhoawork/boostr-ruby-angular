class AddCol2sToUsers < ActiveRecord::Migration
  def change
    add_column :users, :neg_balance_lcnt, :integer
    add_column :users, :pos_balance_lcnt, :integer
  end
end
