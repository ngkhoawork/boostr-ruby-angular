class CreateClientConnections < ActiveRecord::Migration
  def change
    create_table :client_connections, :force => true do |t|
      t.references :agency, references: :clients
      t.references :advertiser, references: :clients
      t.boolean :primary, default: false
      t.boolean :active, default: true

      t.timestamps null: false
    end
  end
end
