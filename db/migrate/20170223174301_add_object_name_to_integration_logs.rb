class AddObjectNameToIntegrationLogs < ActiveRecord::Migration
  def change
    add_column :integration_logs, :object_name, :string
  end
end
