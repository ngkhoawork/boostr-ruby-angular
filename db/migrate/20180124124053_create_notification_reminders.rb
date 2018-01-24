class CreateNotificationReminders < ActiveRecord::Migration
  def change
    create_table :notification_reminders do |t|
      t.string :type
      t.integer :lead_id, index: true
      t.timestamp :sending_time

      t.timestamps null: false
    end
  end
end
