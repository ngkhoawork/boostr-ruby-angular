class RemoveRoleFromContractContacts < ActiveRecord::Migration
  def change
    remove_column :contract_contacts, :role_id, references: :options, index: true
  end
end
