class CreateWorkflow < ActiveRecord::Migration
  def change
    create_table :workflows do |t|
      t.integer :company_id, index: true
      t.integer :user_id,    index: true

      t.string :name
      t.string :description
      t.string :workflowable_type
      t.boolean :switched_on, default: false
      t.boolean :fire_on_update, default: false
      t.boolean :fire_on_create, default: false
      t.boolean :fire_on_destroy, default: false

      t.timestamps null: false
    end
  end
end