class RemoveCompanyIdFromCpmBudgetAdjustments < ActiveRecord::Migration
  def change
    remove_column :cpm_budget_adjustments, :company_id, :integer
  end
end
