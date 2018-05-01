class RestoreContractContactRole < ActiveRecord::Migration
  def change
    unless ContractContact.column_names.include?('role_id')
      add_column :contract_contacts, :role_id, :integer
      add_foreign_key :contract_contacts, :options, column: :role_id
      add_index :contract_contacts, :role_id
    end
  end
end
