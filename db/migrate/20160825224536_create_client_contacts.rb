class CreateClientContacts < ActiveRecord::Migration
  def change
    create_table :client_contacts do |t|
      t.integer :client_id
      t.integer :contact_id
      t.timestamps null: false
    end

    add_index :client_contacts, [:client_id, :contact_id]
  end
end
