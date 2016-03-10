class AddCol3sToUsers < ActiveRecord::Migration
  def change
    add_column :users, :neg_balance_l, :integer
    add_column :users, :pos_balance_l, :integer
  end
end
