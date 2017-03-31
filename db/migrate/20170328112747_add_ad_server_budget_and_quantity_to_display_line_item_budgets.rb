class AddAdServerBudgetAndQuantityToDisplayLineItemBudgets < ActiveRecord::Migration
  def change
    add_column :display_line_item_budgets, :ad_server_budget, :decimal, precision: 15, scale: 2
    add_column :display_line_item_budgets, :ad_server_quantity, :integer
    add_column :display_line_item_budgets, :quantity, :integer
    add_column :display_line_item_budgets, :clicks, :integer
    add_column :display_line_item_budgets, :ctr, :decimal, precision: 2
  end
end
