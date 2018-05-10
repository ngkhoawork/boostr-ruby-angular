class CreateCustomFieldNames < ActiveRecord::Migration
  def change
    create_table :custom_field_names do |t|
      t.string     :subject_type
      t.belongs_to :company, foreign_key: true

      t.integer  :column_index
      t.string   :column_type
      t.string   :field_type
      t.string   :field_label
      t.boolean  :is_required
      t.integer  :position
      t.boolean  :show_on_modal
      t.boolean  :disabled

      t.timestamps null: false
    end

    add_index :custom_field_names, [:company_id, :subject_type, :field_type, :position],
              unique: true, name: 'index_custom_field_names_on_company_subject_field_type_position'
  end
end
