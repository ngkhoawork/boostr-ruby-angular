class CreateStages < ActiveRecord::Migration
  def change
    create_table :stages do |t|
      t.string :name
      t.integer :company_id
      t.integer :probability
      t.boolean :open
      t.boolean :active
      t.integer :deals_count
      t.integer :position
      t.string :color

      t.timestamps null: false
    end
  end
end
