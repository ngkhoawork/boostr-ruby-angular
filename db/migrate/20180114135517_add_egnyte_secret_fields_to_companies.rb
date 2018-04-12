class AddEgnyteSecretFieldsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :egnyte_access_token, :string
    add_column :companies, :egnyte_client_id, :string
    add_column :companies, :egnyte_client_secret, :string
    add_column :companies, :egnyte_connected, :boolean, default: false
    add_column :companies, :egnyte_app_domain, :string
  end
end
