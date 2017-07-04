class ChangeCtrDataTypeForDisplayLineItems < ActiveRecord::Migration
  def change
    change_column :display_line_items, :ctr, :decimal, precision: 5, scale: 4
  end
end
