class CreateAssignmentRules < ActiveRecord::Migration
  def change
    create_table :assignment_rules do |t|
      t.integer :company_id, index: true
      t.text :name
      t.string :countries, array: true, default: []
      t.string :states, array: true, default: []

      t.timestamps null: false
    end
  end
end
