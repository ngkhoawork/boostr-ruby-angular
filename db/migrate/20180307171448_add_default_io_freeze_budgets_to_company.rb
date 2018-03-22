class AddDefaultIoFreezeBudgetsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :default_io_freeze_budgets, :boolean, default: false
  end
end
