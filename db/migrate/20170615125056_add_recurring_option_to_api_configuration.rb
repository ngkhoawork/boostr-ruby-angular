class AddRecurringOptionToApiConfiguration < ActiveRecord::Migration
  def change
    add_column :api_configurations, :recurring, :boolean, default: false
  end
end
