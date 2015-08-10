class AddProductIdToRevenues < ActiveRecord::Migration
  def change
    add_column :revenues, :product_id, :integer
  end
end
