class CreateIntegrations < ActiveRecord::Migration
  def change
    create_table :integrations do |t|
      t.integer :integratable_id
      t.string :integratable_type
      t.string :external_id
      t.string :type

      t.timestamps null: false
    end
  end
end
