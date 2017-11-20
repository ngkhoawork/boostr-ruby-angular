class CreateProductFamilies < ActiveRecord::Migration
  def change
    create_table :product_families do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.string :name
      t.timestamps null: false
    end
  end
end
