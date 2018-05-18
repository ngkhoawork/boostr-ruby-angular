class AddAccountTypeToClients < ActiveRecord::Migration
  def change
    add_column :clients, :account_type, :integer
  end
end
