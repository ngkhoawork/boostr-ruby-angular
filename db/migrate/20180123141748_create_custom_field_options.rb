class CreateCustomFieldOptions < ActiveRecord::Migration
  def change
    create_table :custom_field_options do |t|
      t.belongs_to :custom_field_name, index: true, foreign_key: true
      t.string :value

      t.timestamps null: false
    end
  end
end
