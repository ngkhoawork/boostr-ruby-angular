class CreateWorkflowLogs < ActiveRecord::Migration
  def change
    create_table :workflow_logs do |t|
      t.integer :company_id, index: true
      t.integer :workflow_id, index: true

      t.string :workflowable_type
      t.boolean :criteria_passed
      t.boolean :workflow_successful
      t.text :workflow_result
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps null: false
    end
  end
end