class AddCtrClicksToDisplayLineItems < ActiveRecord::Migration
  def change
    add_column :display_line_items, :ctr, :decimal, precision: 3, scale: 2
    add_column :display_line_items, :clicks, :integer
  end
end
