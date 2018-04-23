class AddAssignmentRulesUsersTable < ActiveRecord::Migration
  def change
    create_table :assignment_rules_users do |t|
      t.integer :assignment_rule_id, index: true
      t.integer :user_id, index: true
      t.integer :position
      t.boolean :next, default: false

      t.timestamps null: false
    end
  end
end
