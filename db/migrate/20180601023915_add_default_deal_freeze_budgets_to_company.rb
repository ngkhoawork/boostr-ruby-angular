class AddDefaultDealFreezeBudgetsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :default_deal_freeze_budgets, :boolean, default: false
  end
end
