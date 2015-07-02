class CreateLicenses < ActiveRecord::Migration
  def change
    create_table :licenses do |t|
      t.string :name
      t.integer :quantity
      t.integer :cost

      t.timestamps null: false
    end
  end
end
