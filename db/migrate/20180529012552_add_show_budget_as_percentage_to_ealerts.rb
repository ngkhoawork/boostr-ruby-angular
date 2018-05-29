class AddShowBudgetAsPercentageToEalerts < ActiveRecord::Migration
  def change
    add_column :ealerts, :show_budget_as_percentage, :boolean, default: true
  end
end
