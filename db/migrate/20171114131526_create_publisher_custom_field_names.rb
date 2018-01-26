class CreatePublisherCustomFieldNames < ActiveRecord::Migration
  def change
    create_table :publisher_custom_field_names do |t|
      t.integer :company_id, index: true
      t.integer :field_index
      t.string :field_type
      t.string :field_label
      t.boolean :is_required
      t.integer :position
      t.boolean :show_on_modal
      t.boolean :disabled

      t.timestamps null: false
    end
  end
end
