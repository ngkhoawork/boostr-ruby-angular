class ChangeDataTypeForRevenueAmount < ActiveRecord::Migration
  def up
    change_column :account_revenue_facts, :revenue_amount, :decimal, precision: 9, scale: 2
  end

  def down
    change_column :account_revenue_facts, :revenue_amount, :integer
  end
end
