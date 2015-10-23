class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.integer :company_id
      t.integer :field_id
      t.string :name
      t.integer :position
      t.datetime :deleted_at
      t.boolean :locked, default: false

      t.timestamps null: false
    end

    add_index :options, [:company_id, :field_id, :position, :deleted_at], name: :options_index_composite
  end
end
