class AddParentClientIdToClients < ActiveRecord::Migration
  def change
    add_column :clients, :parent_client_id, :integer
    add_foreign_key :clients, :clients, column: :parent_client_id, primary_key: :id
  end
end
