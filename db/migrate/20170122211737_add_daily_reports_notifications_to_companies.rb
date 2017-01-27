class AddDailyReportsNotificationsToCompanies < ActiveRecord::Migration
  def up
    company_ids = Company.pluck(:id)
    company_ids.each do |company_id|
      Notification.create(name: 'Deal Reports', active: true, company_id: company_id)
    end
  end

  def down
    Notification.where(name: 'Deal Reports').destroy_all
  end
end
