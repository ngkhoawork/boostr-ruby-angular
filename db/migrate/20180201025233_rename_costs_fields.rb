class RenameCostsFields < ActiveRecord::Migration
  def change
    rename_column :costs, :total_cost, :budget
    rename_column :costs, :total_cost_loc, :budget_loc
  end
end
