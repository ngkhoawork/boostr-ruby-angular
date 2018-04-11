class AddLegacyIdToDealsAndClients < ActiveRecord::Migration
  def change
    add_column :deals, :legacy_id, :string
    add_column :clients, :legacy_id, :string
  end
end
