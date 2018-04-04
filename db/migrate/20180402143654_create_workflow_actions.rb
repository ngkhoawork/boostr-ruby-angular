class CreateWorkflowActions < ActiveRecord::Migration
  def change
    create_table :workflow_actions do |t|
      t.integer :workflow_id, index: true
      t.integer :api_configuration_id, index: true

      t.string :workflow_type
      t.string :workflow_method
      t.string :template

      t.timestamps null: false
    end
  end
end