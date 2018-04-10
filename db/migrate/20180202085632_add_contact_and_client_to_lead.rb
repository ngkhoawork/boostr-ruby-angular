class AddContactAndClientToLead < ActiveRecord::Migration
  def change
    add_column :leads, :client_id, :integer
    add_column :leads, :contact_id, :integer
    add_index :leads, :client_id
    add_index :leads, :contact_id
  end
end
