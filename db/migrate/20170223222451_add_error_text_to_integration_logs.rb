class AddErrorTextToIntegrationLogs < ActiveRecord::Migration
  def change
    add_column :integration_logs, :error_text, :text
  end
end
