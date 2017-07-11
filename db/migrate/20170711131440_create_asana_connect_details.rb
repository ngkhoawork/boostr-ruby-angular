class CreateAsanaConnectDetails < ActiveRecord::Migration
  def change
    create_table :asana_connect_details do |t|
      t.string :project_name
      t.string :workspace_name
      t.references :company, index: true, foreign_key: true
      t.references :api_configuration, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
