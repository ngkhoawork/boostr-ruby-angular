class SetFieldTypeValueForExistedAssignmentRules < ActiveRecord::Migration
  def change
    AssignmentRule.update_all(field_type: AssignmentRule::COUNTRY)
  end
end
