class CreateDealContacts < ActiveRecord::Migration
  def change
    create_table :deal_contacts do |t|
      t.integer :deal_id
      t.integer :contact_id
      t.timestamps null: false
    end

    add_index :deal_contacts, [:deal_id, :contact_id]
  end
end
