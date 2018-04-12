class DeleteAssignmentRulesUsersTable < ActiveRecord::Migration
  def change
    drop_table :assignment_rules_users
  end
end
