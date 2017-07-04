class AddApiConfigurationReferenceToCpmBudgetAdjustmens < ActiveRecord::Migration
  def change
    add_reference :cpm_budget_adjustments, :api_configuration, index: true, foreign_key: true
  end
end
