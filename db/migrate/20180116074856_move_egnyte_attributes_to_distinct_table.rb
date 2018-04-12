class MoveEgnyteAttributesToDistinctTable < ActiveRecord::Migration
  def change
    remove_column :companies, :egnyte_client_id, :string
    remove_column :companies, :egnyte_client_secret, :string
    remove_column :companies, :egnyte_app_domain, :string
    remove_column :companies, :egnyte_access_token, :string
    remove_column :companies, :egnyte_connected, :boolean, default: false
    remove_column :companies, :egnyte_enabled, :boolean, default: false

    create_table :egnyte_integrations do |t|
      t.references :company, index: true, foreign_key: true

      t.string :app_domain
      t.string :access_token
      t.boolean :connected, default: false
      t.boolean :enabled, default: false

      t.timestamps null: false
    end
  end
end
