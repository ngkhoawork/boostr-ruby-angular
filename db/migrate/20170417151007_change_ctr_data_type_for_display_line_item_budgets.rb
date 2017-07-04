class ChangeCtrDataTypeForDisplayLineItemBudgets < ActiveRecord::Migration
  def change
    change_column :display_line_item_budgets, :ctr, :decimal, precision: 5, scale: 4
  end
end
