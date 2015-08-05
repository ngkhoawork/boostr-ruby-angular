class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.integer :company_id
      t.string :product_line
      t.string :family
      t.string :pricing_type

      t.timestamps null: false
    end
  end
end
