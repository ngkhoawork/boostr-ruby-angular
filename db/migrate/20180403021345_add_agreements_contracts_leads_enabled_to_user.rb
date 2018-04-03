class AddAgreementsContractsLeadsEnabledToUser < ActiveRecord::Migration
  def change
    add_column :users, :agreements_enabled, :boolean
    add_column :users, :contracts_enabled, :boolean
    add_column :users, :leads_enabled, :boolean
  end
end
