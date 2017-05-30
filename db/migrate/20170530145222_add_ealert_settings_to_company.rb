class AddEalertSettingsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :ealert_reminder, :boolean, default: false
  end
end
