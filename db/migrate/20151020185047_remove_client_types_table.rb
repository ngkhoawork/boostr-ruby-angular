class RemoveClientTypesTable < ActiveRecord::Migration
  def change
    drop_table :client_types
  end
end
