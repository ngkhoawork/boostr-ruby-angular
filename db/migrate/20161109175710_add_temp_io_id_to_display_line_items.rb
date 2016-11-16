class AddTempIoIdToDisplayLineItems < ActiveRecord::Migration
  def change
    add_reference :display_line_items, :temp_io, foreign_key: true
  end
end
