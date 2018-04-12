class CreateWorkflowCriterions < ActiveRecord::Migration
  def change
    create_table :workflow_criterions do |t|
      t.integer :workflow_id, index: true
      t.integer :workflow_criterion_id, index: true

      t.integer :parent_criterion_id
      t.string :base_object
      t.string :field
      t.string :math_operator
      t.string :value
      t.string :relation
      t.string :data_type

      t.timestamps null: false
    end
  end
end
