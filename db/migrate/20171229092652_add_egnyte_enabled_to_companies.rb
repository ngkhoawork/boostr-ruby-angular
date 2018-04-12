class AddEgnyteEnabledToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :egnyte_enabled, :boolean, default: false
  end
end
