class AddPriceToDisplayLineItems < ActiveRecord::Migration
  def change
    add_column :display_line_items, :price, :bigint
  end
end
