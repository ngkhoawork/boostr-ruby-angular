class ExtendDisplayLineItemBudgets < ActiveRecord::Migration
  def up
    change_column :display_line_item_budgets, :display_line_item_id, :integer, limit: 8
    change_column :display_line_item_budgets, :external_io_number, :integer, limit: 8
    change_column :display_line_item_budgets, :budget, :decimal, precision: 15, scale: 2, default: 0.0
    change_column :display_line_item_budgets, :ad_server_quantity, :integer, limit: 8
    change_column :display_line_item_budgets, :quantity, :integer, limit: 8
    change_column :display_line_item_budgets, :clicks, :integer, limit: 8
  end

  def down
    change_column :display_line_item_budgets, :display_line_item_id, :integer
    change_column :display_line_item_budgets, :external_io_number, :integer
    change_column :display_line_item_budgets, :budget, :float
    change_column :display_line_item_budgets, :ad_server_quantity, :integer
    change_column :display_line_item_budgets, :quantity, :integer
    change_column :display_line_item_budgets, :clicks, :integer
  end
end