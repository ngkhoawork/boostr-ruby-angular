class AddLeadIdToContacts < ActiveRecord::Migration
  def change
    add_column :contacts, :lead_id, :integer
    add_index :contacts, :lead_id
  end
end
