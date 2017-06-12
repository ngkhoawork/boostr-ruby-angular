class AddLostDealNotifications < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.notifications.find_or_create_by(name: 'Lost Deal', active: true)
    end
  end
end
