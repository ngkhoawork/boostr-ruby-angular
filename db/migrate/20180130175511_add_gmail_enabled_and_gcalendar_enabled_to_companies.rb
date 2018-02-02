class AddGmailEnabledAndGcalendarEnabledToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :gmail_enabled, :boolean, default: false
    add_column :companies, :gcalendar_enabled, :boolean, default: false
  end
end
