class AddDfpQueryTypeToIntegrationLogs < ActiveRecord::Migration
  def change
    add_column :integration_logs, :dfp_query_type, :string
  end
end
