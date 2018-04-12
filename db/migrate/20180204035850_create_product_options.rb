class CreateProductOptions < ActiveRecord::Migration
  def change
    create_table :product_options do |t|
      t.string :name
      t.datetime :deleted_at
      t.references :company, index: true, foreign_key: true
      t.references :product_option, index: true, foreign_key: true
      t.timestamps
    end
  end
end
