class AddDailyBudgetToRevenue < ActiveRecord::Migration
  def change
    add_column :revenues, :daily_budget, :integer
  end
end
