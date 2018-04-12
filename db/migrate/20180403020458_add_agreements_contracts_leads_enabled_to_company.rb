class AddAgreementsContractsLeadsEnabledToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :agreements_enabled, :boolean
    add_column :companies, :contracts_enabled, :boolean
    add_column :companies, :leads_enabled, :boolean
  end
end
