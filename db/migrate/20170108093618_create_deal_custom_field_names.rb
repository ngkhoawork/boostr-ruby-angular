class CreateDealCustomFieldNames < ActiveRecord::Migration
  def change
    create_table :deal_custom_field_names do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.integer :field_index
      t.string :type
      t.string :label

      t.timestamps null: false
    end
  end
end
