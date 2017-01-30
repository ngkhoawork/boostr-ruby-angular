class AddBalanceLocToDisplayLineItems < ActiveRecord::Migration
  def change
    add_column :display_line_items, :balance_loc, :bigint
    add_column :display_line_items, :daily_run_rate_loc, :integer
  end
end
