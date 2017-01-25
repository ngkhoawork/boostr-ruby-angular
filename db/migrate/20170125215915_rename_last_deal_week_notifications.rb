class RenameLastDealWeekNotifications < ActiveRecord::Migration
  def change
    notifications = Notification.where('notifications.name = \'Deal Reports\'')
    notifications.update_all(name: 'Pipeline Changes Reports')
  end
end
