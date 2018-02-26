class AddPmpStoppedRunningNotifications < ActiveRecord::Migration
  def up
    Company.all.each do |company|
      company.notifications.find_or_create_by(name: Notification::PMP_STOPPED_RUNNING, active: true)
    end
  end

  def down
    Notification.where(name: Notification::PMP_STOPPED_RUNNING).destroy_all
  end
end
