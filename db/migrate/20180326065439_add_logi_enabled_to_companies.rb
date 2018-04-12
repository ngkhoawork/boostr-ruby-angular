class AddLogiEnabledToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :logi_enabled, :boolean, default: false
  end
end
