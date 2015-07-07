class AddLicenseDataToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :quantity, :integer
    add_column :companies, :cost, :integer
    add_column :companies, :start_date, :datetime
    add_column :companies, :end_date, :datetime
  end
end
