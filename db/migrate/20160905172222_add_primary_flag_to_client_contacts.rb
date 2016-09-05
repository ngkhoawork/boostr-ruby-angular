class AddPrimaryFlagToClientContacts < ActiveRecord::Migration
  def change
    add_column :client_contacts, :primary, :boolean, default: false, null: false
  end
end
