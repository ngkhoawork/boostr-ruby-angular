class AddActivityTypeIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :activity_type_id, :integer
  end
end
