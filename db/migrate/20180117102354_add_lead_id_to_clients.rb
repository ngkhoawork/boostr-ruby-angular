class AddLeadIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :lead_id, :integer
    add_index :clients, :lead_id
  end
end
