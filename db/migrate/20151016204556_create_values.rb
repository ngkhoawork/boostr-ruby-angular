class CreateValues < ActiveRecord::Migration
  def change
    create_table :values do |t|
      t.integer :company_id
      t.string :subject_type
      t.integer :subject_id
      t.integer :field_id
      t.string :value_type
      t.text :value_text
      t.integer :value_number
      t.float :value_float
      t.datetime :value_datetime
      t.integer :value_object_id
      t.string :value_object_type
      t.integer :option_id

      t.timestamps null: false
    end

    add_index :values, [:company_id, :field_id]
    add_index :values, [:subject_type, :subject_id]
    add_index :values, [:value_object_type, :value_object_id]
    add_index :values, :option_id
  end
end
