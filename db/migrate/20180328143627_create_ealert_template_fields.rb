class CreateEalertTemplateFields < ActiveRecord::Migration
  def change
    create_table :ealert_template_fields do |t|
      t.references :ealert_template, foreign_key: true, null: false
      t.string :name
      t.integer :position

      t.timestamps null: false
    end

    add_index :ealert_template_fields, [:ealert_template_id, :position], unique: true
  end
end
