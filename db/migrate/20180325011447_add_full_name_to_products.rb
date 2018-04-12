class AddFullNameToProducts < ActiveRecord::Migration
  def up
    add_column :products, :full_name, :string
    add_column :products, :auto_generated, :boolean

    Product.all.each do |product|
      product.full_name = product.generate_full_name
      product.auto_generated = true
      product.save
    end
  end

  def down
    remove_column :products, :full_name
    remove_column :products, :auto_generated
  end
end
