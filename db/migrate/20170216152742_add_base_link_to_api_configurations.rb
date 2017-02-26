class AddBaseLinkToApiConfigurations < ActiveRecord::Migration
  def change
    add_column :api_configurations, :base_link, :string
  end
end
