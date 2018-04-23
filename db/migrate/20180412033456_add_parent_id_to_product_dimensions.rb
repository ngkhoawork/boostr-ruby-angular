class AddParentIdToProductDimensions < ActiveRecord::Migration
  def up
    add_column :product_dimensions, :parent_id, :integer
    add_column :product_dimensions, :top_parent_id, :integer
    ProductDimension.update_all('top_parent_id = id')
  end

  def down
    remove_column :product_dimensions, :parent_id
    remove_column :product_dimensions, :top_parent_id
  end
end
