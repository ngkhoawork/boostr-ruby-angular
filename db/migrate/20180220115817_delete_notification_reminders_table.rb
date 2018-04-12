class DeleteNotificationRemindersTable < ActiveRecord::Migration
  def change
    drop_table :notification_reminders
  end
end
