class SwitchContentFeesToDecimal < ActiveRecord::Migration
  def change
    change_column :content_fee_product_budgets, :budget, :decimal, precision: 15, scale: 2
    change_column :content_fees, :budget, :decimal, precision: 15, scale: 2
  end
end
