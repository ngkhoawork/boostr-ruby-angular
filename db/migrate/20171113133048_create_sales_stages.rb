class CreateSalesStages < ActiveRecord::Migration
  def change
    create_table :sales_stages do |t|
      t.integer :sales_stageable_id, index: true
      t.string :sales_stageable_type, index: true
      t.integer :company_id, index: true
      t.string :name
      t.integer :probability
      t.boolean :open
      t.boolean :active
      t.integer :position

      t.timestamps null: false
    end
  end
end
