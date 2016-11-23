class AddNewDealNotification < ActiveRecord::Migration
  def change
    Company.all.each do |company|
      company.notifications.find_or_create_by(name: 'New Deal', active: true)
    end
  end
end
