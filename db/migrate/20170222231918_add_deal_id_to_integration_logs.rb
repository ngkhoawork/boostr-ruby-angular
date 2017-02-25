class AddDealIdToIntegrationLogs < ActiveRecord::Migration
  def change
    add_column :integration_logs, :deal_id, :integer
  end
end
