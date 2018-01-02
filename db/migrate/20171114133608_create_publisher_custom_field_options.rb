class CreatePublisherCustomFieldOptions < ActiveRecord::Migration
  def change
    create_table :publisher_custom_field_options do |t|
      t.integer :publisher_custom_field_name_id, index: { name: 'index_publisher_cf_options_on_publisher_cf_name_id' }
      t.string :value

      t.timestamps null: false
    end
  end
end
