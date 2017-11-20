class AddProductFamilyToProducts < ActiveRecord::Migration
  def change
    add_reference :products, :product_family, index: true
  end
end
