class AddEncryptedJsonApiKeyToApiConfigurations < ActiveRecord::Migration
  def change
    add_column :api_configurations, :encrypted_json_api_key, :text
    add_column :api_configurations, :encrypted_json_api_key_iv, :text
  end
end
