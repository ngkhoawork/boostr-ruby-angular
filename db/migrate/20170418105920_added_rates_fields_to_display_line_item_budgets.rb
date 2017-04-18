class AddedRatesFieldsToDisplayLineItemBudgets < ActiveRecord::Migration
  def change
    add_column :display_line_item_budgets, :video_avg_view_rate, :decimal, precision: 5, scale: 4
    add_column :display_line_item_budgets, :video_completion_rate, :decimal, precision: 5, scale: 4
  end
end
