class IncreasePrecisionForBudgets < ActiveRecord::Migration
  def up
    change_column :deals, :budget, :decimal, precision: 15, scale: 2, default: 0
    change_column :deal_products, :budget, :decimal, precision: 15, scale: 2, default: 0
    change_column :deal_product_budgets, :budget, :decimal, precision: 15, scale: 2, default: 0
    change_column :deal_logs, :budget_change, :decimal, precision: 15, scale: 2
  end

  def down
    change_column :deals, :budget, :decimal, precision: 12, scale: 2, default: 0
    change_column :deal_products, :budget, :decimal, precision: 12, scale: 2, default: 0
    change_column :deal_product_budgets, :budget, :decimal, precision: 12, scale: 2, default: 0
    change_column :deal_logs, :budget_change, :decimal, precision: 12, scale: 2
  end
end
