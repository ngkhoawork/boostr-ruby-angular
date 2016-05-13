class RenameColorColumnsOnStagesAndCompanies < ActiveRecord::Migration
  def change
    remove_column :stages, :day1
    rename_column :stages, :day2, :yellow_threshold
    rename_column :stages, :day3, :red_threshold

    remove_column :companies, :day1
    rename_column :companies, :day2, :yellow_threshold
    rename_column :companies, :day3, :red_threshold
  end
end
