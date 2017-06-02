class AddStatusFlagToClientContacts < ActiveRecord::Migration
  def change
    add_column :client_contacts, :is_active, :boolean, default: true, null: false
  end
end
