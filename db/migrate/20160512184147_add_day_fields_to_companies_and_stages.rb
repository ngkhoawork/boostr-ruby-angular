class AddDayFieldsToCompaniesAndStages < ActiveRecord::Migration
  def change
    add_column :companies, :avg_day, :integer
    add_column :companies, :day1, :integer
    add_column :companies, :day2, :integer
    add_column :companies, :day3, :integer
    add_column :stages, :avg_day, :integer
    add_column :stages, :day1, :integer
    add_column :stages, :day2, :integer
    add_column :stages, :day3, :integer
  end
end
