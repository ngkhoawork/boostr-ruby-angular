class CreateFields < ActiveRecord::Migration
  def change
    create_table :fields do |t|
      t.integer :company_id
      t.string :subject_type
      t.string :value_type
      t.string :value_object_type
      t.string :name
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :fields, :company_id
    add_index :fields, :subject_type
    add_index :fields, :deleted_at
  end
end
