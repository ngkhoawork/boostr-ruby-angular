class RemoveUnusedDayFieldsFromStagesAndCompanies < ActiveRecord::Migration
  def change
    remove_column :companies, :avg_day
    remove_column :stages, :avg_day
  end
end
