class AddIntegrationProviderToApiConfigurations < ActiveRecord::Migration
  def change
    add_column :api_configurations, :integration_provider, :string
  end
end
