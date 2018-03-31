class AddIsMultibuyerClients < ActiveRecord::Migration
  def change
    add_column :clients, :is_multibuyer, :boolean, default: false
  end
end
