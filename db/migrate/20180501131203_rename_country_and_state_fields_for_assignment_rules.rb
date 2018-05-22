class RenameCountryAndStateFieldsForAssignmentRules < ActiveRecord::Migration
  def change
    rename_column :assignment_rules, :countries, :criteria_1
    rename_column :assignment_rules, :states, :criteria_2
  end
end
