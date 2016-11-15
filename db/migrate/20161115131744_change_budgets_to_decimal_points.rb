class ChangeBudgetsToDecimalPoints < ActiveRecord::Migration
  def change
    change_column :ios, :budget, :decimal, precision: 15, scale: 2
    change_column :display_line_items, :price, :decimal, precision: 15, scale: 2
    change_column :display_line_items, :budget, :decimal, precision: 15, scale: 2
    change_column :display_line_items, :budget_delivered, :decimal, precision: 15, scale: 2
    change_column :display_line_items, :budget_remaining, :decimal, precision: 15, scale: 2
    change_column :display_line_items, :budget_delivered_3p, :decimal, precision: 15, scale: 2
    change_column :display_line_items, :budget_remaining_3p, :decimal, precision: 15, scale: 2
  end
end
