class AddDayFieldsToCompaniesAndStages < ActiveRecord::Migration
  def change
    add_column :companies, :avg_day, :string
    add_column :companies, :day1, :string
    add_column :companies, :day2, :string
    add_column :companies, :day3, :string
    add_column :stages, :avg_day, :string
    add_column :stages, :day1, :string
    add_column :stages, :day2, :string
    add_column :stages, :day3, :string
  end
end
