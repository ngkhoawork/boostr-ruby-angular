class AddStateTokenToEgnyteIntegrations < ActiveRecord::Migration
  def change
    add_column :egnyte_integrations, :state_token, :string
    remove_column :egnyte_integrations, :connected, :boolean
  end
end
