class AddOptionsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :option1_id, :integer
    add_column :products, :option2_id, :integer
    add_index :products, %i(name company_id option1_id option2_id), unique: true, name: 'index_composite'
  end
end
