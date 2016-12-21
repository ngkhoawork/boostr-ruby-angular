class ChangeDataTypeForRevenueAmount < ActiveRecord::Migration
  def change
    change_column :account_revenue_facts, :revenue_amount, :decimal, precision: 9, scale: 2
  end
end
