class RemoveFieldTypeValueForDefaultRule < ActiveRecord::Migration
  def change
    AssignmentRule.where(default: true).update_all(field_type: nil)
  end
end
