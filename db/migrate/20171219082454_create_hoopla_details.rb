class CreateHooplaDetails < ActiveRecord::Migration
  def change
    create_table :hoopla_details do |t|
      t.references :api_configuration, foreign_key: true, index: true

      t.string :client_id
      t.string :client_secret
      t.boolean :connected, default: false
      t.string :access_token
      t.datetime :access_token_expires_at
      t.string :deal_won_newsflash_href

      t.timestamps null: false
    end
  end
end
