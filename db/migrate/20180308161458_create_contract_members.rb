class CreateContractMembers < ActiveRecord::Migration
  def change
    create_table :contract_members do |t|
      t.references :contract, foreign_key: true, null: false
      t.references :user, foreign_key: true, null: false
      t.references :role, references: :options, index: true

      t.timestamps null: false
    end

    add_foreign_key :contract_members, :options, column: :role_id
    add_index :contract_members, [:contract_id, :user_id], unique: true
  end
end
