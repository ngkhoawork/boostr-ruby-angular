class AddIsErrorToIntegrationLogs < ActiveRecord::Migration
  def change
    add_column :integration_logs, :is_error, :boolean
  end
end
