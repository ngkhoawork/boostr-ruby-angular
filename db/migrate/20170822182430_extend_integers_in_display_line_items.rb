class ExtendIntegersInDisplayLineItems < ActiveRecord::Migration
  def up
    change_column :display_line_items, :io_id, :integer, limit: 8
    change_column :display_line_items, :line_number, :integer, limit: 8
    change_column :display_line_items, :quantity, :integer, limit: 8
    change_column :display_line_items, :product_id, :integer, limit: 8
    change_column :display_line_items, :quantity_delivered, :integer, limit: 8
    change_column :display_line_items, :quantity_remaining, :integer, limit: 8
    change_column :display_line_items, :daily_run_rate, :integer, limit: 8
    change_column :display_line_items, :quantity_delivered_3p, :integer, limit: 8
    change_column :display_line_items, :quantity_remaining_3p, :integer, limit: 8
    change_column :display_line_items, :temp_io_id, :integer, limit: 8
    change_column :display_line_items, :daily_run_rate_loc, :integer, limit: 8
    change_column :display_line_items, :clicks, :integer, limit: 8
  end

  def down
    change_column :display_line_items, :io_id, :integer, limit: 4
    change_column :display_line_items, :line_number, :integer, limit: 4
    change_column :display_line_items, :quantity, :integer, limit: 4
    change_column :display_line_items, :product_id, :integer, limit: 4
    change_column :display_line_items, :quantity_delivered, :integer, limit: 4
    change_column :display_line_items, :quantity_remaining, :integer, limit: 4
    change_column :display_line_items, :daily_run_rate, :integer, limit: 4
    change_column :display_line_items, :quantity_delivered_3p, :integer, limit: 4
    change_column :display_line_items, :quantity_remaining_3p, :integer, limit: 4
    change_column :display_line_items, :temp_io_id, :integer, limit: 4
    change_column :display_line_items, :daily_run_rate_loc, :integer, limit: 4
    change_column :display_line_items, :clicks, :integer, limit: 4
  end
end
