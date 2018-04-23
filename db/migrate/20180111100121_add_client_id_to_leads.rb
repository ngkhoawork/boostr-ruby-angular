class AddClientIdToLeads < ActiveRecord::Migration
  def change
    add_column :leads, :client_id, :integer
    add_index :leads, :client_id
  end
end
