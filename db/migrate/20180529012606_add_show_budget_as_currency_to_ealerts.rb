class AddShowBudgetAsCurrencyToEalerts < ActiveRecord::Migration
  def change
    add_column :ealerts, :show_budget_as_currency, :boolean, default: false
  end
end
