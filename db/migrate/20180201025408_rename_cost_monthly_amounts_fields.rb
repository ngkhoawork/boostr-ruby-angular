class RenameCostMonthlyAmountsFields < ActiveRecord::Migration
  def change
    rename_column :cost_monthly_amounts, :cost, :budget
    rename_column :cost_monthly_amounts, :cost_loc, :budget_loc
  end
end
