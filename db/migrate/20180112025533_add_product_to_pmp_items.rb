class AddProductToPmpItems < ActiveRecord::Migration
  def change
    add_column :pmp_items, :product_id, :integer
    add_index :pmp_items, :product_id
  end
end
