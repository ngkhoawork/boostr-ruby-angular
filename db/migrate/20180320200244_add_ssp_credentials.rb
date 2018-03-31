class AddSspCredentials < ActiveRecord::Migration
  def change
    create_table :ssp_credentials do |t|
      t.integer :company_id
      t.string :key, null: false
      t.string :secret, null: false
      t.integer :publisher_id, null: false
      t.integer :ssp_id
      t.integer :type_id, default: 1
      t.boolean :switched_on, default: true
      t.string :parser_type, default: 'rubicon'
      t.string :integration_type
      t.string :integration_provider
      t.timestamps
    end
    add_index :ssp_credentials, :company_id
    add_index :ssp_credentials, :ssp_id
  end
end
