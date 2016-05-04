class CreateActivityTypes < ActiveRecord::Migration
  def change
    create_table :activity_types do |t|
      t.integer :company_id
      t.string :name
      t.string :action
      t.string :icon
      t.integer :updated_by
      t.integer :created_by

      t.timestamps null: false
    end
  end
end
