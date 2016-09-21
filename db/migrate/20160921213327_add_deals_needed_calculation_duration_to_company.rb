class AddDealsNeededCalculationDurationToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :deals_needed_calculation_duration, :integer, default: 90
  end
end
