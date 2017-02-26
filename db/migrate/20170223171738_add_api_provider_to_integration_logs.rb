class AddApiProviderToIntegrationLogs < ActiveRecord::Migration
  def change
    add_column :integration_logs, :api_provider, :string
  end
end
