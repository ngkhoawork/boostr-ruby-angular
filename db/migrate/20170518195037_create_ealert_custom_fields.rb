class CreateEalertCustomFields < ActiveRecord::Migration
  def change
    create_table :ealert_custom_fields do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.belongs_to :ealert, index: true, foreign_key: true
      t.string :subject_type
      t.integer :subject_id
      t.integer :position, limit: 2, default: 0

      t.timestamps null: false
    end
  end
end
