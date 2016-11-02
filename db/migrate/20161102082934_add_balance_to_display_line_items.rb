class AddBalanceToDisplayLineItems < ActiveRecord::Migration
  def change
    add_column :display_line_items, :balance, :bigint
    add_column :display_line_items, :last_alert_at, :datetime
  end
end
