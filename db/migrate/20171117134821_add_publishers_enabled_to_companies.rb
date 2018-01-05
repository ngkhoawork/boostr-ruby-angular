class AddPublishersEnabledToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :publishers_enabled, :boolean, default: false
  end
end
