class AddPmpTypeToDealProductsAndPmpItems < ActiveRecord::Migration
  def up
    remove_column :deal_products, :is_guaranteed
    remove_column :pmp_items, :is_guaranteed
    add_column :deal_products, :pmp_type, :integer
    add_column :pmp_items, :pmp_type, :integer
  end

  def down
    remove_column :deal_products, :pmp_type
    remove_column :pmp_items, :pmp_type
    add_column :deal_products, :is_guaranteed, :boolean, default: false
    add_column :pmp_items, :is_guaranteed, :boolean, default: false
  end
end
