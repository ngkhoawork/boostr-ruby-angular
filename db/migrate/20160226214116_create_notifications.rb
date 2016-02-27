class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :company_id
      t.string :name
      t.string :subject
      t.text :message
      t.boolean :active
      t.text :recipients

      t.timestamps null: false
    end
  end
end
