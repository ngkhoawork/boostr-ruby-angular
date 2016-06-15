class AddGoogleEventIdToActivities < ActiveRecord::Migration
  def change
    add_column :activities, :google_event_id, :string
  end
end
