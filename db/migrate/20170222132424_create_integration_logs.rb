class CreateIntegrationLogs < ActiveRecord::Migration
  def change
    create_table :integration_logs do |t|
      t.text :request_body
      t.string :response_code
      t.text :response_body
      t.string :api_endpoint
      t.string :request_type
      t.string :resource_type
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
