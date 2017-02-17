class AddEncryptedPasswordToApiConfigurations < ActiveRecord::Migration
  def change
    add_column :api_configurations, :encrypted_password, :string
    add_column :api_configurations, :encrypted_password_iv, :string
  end
end
