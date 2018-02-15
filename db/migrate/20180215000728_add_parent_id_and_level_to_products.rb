class AddParentIdAndLevelToProducts < ActiveRecord::Migration
  def change
    add_column :products, :parent_id, :integer
    add_column :products, :top_parent_id, :integer
    add_column :products, :level, :integer, default: 0
    add_index :products, :parent_id
    add_index :products, :top_parent_id
  end
end
