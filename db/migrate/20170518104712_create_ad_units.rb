class CreateAdUnits < ActiveRecord::Migration
  def change
    create_table :ad_units do |t|
      t.text :name
      t.references :product, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
