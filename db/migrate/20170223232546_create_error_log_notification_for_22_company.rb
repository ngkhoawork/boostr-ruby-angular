class CreateErrorLogNotificationFor22Company < ActiveRecord::Migration
  def change
    Notification.create(company_id: 22, active: false, name: 'Error Log')
  end
end
