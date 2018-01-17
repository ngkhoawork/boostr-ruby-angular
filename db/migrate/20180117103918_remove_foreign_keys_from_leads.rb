class RemoveForeignKeysFromLeads < ActiveRecord::Migration
  def change
    remove_column :leads, :contact_id, :integer
    remove_column :leads, :client_id, :integer
  end
end
