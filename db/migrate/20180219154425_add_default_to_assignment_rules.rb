class AddDefaultToAssignmentRules < ActiveRecord::Migration
  def change
    add_column :assignment_rules, :default, :boolean, default: false
  end
end
