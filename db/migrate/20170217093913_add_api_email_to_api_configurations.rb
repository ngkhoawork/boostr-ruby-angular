class AddApiEmailToApiConfigurations < ActiveRecord::Migration
  def change
    add_column :api_configurations, :api_email, :string
  end
end
