class AddTimedToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :timed, :boolean
  end
end
