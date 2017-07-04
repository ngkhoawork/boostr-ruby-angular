class AddNetworkCodeToApiConfigurations < ActiveRecord::Migration
  def change
    add_column :api_configurations, :network_code, :string
  end
end
