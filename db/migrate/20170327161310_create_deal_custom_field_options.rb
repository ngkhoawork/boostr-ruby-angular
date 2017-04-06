class CreateDealCustomFieldOptions < ActiveRecord::Migration
  def change
    create_table :deal_custom_field_options do |t|
      t.belongs_to :deal_custom_field_name, index: true, foreign_key: true
      t.string :value

      t.timestamps null: false
    end
  end
end
