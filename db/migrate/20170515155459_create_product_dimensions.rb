class CreateProductDimensions < ActiveRecord::Migration
  def change
    create_table :product_dimensions do |t|
      t.string :name
      t.string :revenue_type
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
