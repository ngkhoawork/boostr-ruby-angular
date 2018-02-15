class AddPositionToAssignmentRule < ActiveRecord::Migration
  def change
    add_column :assignment_rules, :position, :integer
  end
end
