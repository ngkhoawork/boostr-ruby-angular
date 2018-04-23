class DeleteProductOptions < ActiveRecord::Migration
  def up
    remove_column :products, :option1_id
    remove_column :products, :option2_id

    drop_table :product_options
  end

  def down
    add_column :products, :option1_id, :integer
    add_column :products, :option2_id, :integer
    add_index :products, %i(name company_id option1_id option2_id), unique: true, name: 'index_composite'

    create_table :product_options do |t|
      t.string :name
      t.datetime :deleted_at
      t.references :company, index: true, foreign_key: true
      t.references :product_option, index: true, foreign_key: true
      t.timestamps
    end
  end
end
