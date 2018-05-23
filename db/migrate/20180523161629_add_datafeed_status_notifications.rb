class AddDatafeedStatusNotifications < ActiveRecord::Migration
    def up
    Company.all.find_each do |company|
      company.notifications.find_or_create_by(name: Notification::DATAFEED_STATUS, active: true)
    end
  end

  def down
    Notification.where(name: Notification::DATAFEED_STATUS).destroy_all
  end
end
