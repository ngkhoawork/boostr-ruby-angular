class AddFieldTypeToAssignmentRule < ActiveRecord::Migration
  def change
    add_column :assignment_rules, :field_type, :string, index: true
  end
end
