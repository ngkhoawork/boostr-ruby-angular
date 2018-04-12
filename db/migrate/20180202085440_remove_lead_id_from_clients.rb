class RemoveLeadIdFromClients < ActiveRecord::Migration
  def change
    remove_column :clients, :lead_id, :integer
  end
end
