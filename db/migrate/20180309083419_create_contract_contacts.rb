class CreateContractContacts < ActiveRecord::Migration
  def change
    create_table :contract_contacts do |t|
      t.references :contract, foreign_key: true, null: false
      t.references :contact, foreign_key: true, null: false
      t.references :role, references: :options, index: true

      t.timestamps null: false
    end

    add_foreign_key :contract_contacts, :options, column: :role_id
    add_index :contract_contacts, [:contract_id, :contact_id], unique: true
  end
end
