class AddAddServerProductToDisplay < ActiveRecord::Migration
  def change
    add_column :display_line_items, :ad_server_product, :string
  end
end
