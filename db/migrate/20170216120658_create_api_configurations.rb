class CreateApiConfigurations < ActiveRecord::Migration
  def change
    create_table :api_configurations do |t|
      t.string :integration_type
      t.boolean :switched_on
      t.integer :trigger_on_deal_percentage
      t.references :company, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
