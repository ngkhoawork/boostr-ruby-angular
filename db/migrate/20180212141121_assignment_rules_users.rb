class AssignmentRulesUsers < ActiveRecord::Migration
  def change
    create_table :assignment_rules_users, id: false do |t|
      t.belongs_to :assignment_rule
      t.belongs_to :user
    end
  end
end
