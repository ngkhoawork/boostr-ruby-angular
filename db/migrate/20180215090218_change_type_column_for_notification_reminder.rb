class ChangeTypeColumnForNotificationReminder < ActiveRecord::Migration
  def change
    rename_column :notification_reminders, :type, :notification_type
  end
end
