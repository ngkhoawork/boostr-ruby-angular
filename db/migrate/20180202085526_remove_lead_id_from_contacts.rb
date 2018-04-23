class RemoveLeadIdFromContacts < ActiveRecord::Migration
  def change
    remove_column :contacts, :lead_id, :integer
  end
end
