class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :position
      t.integer :client_id
      t.integer :created_by
      t.integer :updated_by

      t.timestamps null: false
    end
  end
end
