class AddRevenueCalculationPatternToDatafeedConfigurationDetails < ActiveRecord::Migration
  def change
    add_column :datafeed_configuration_details, :revenue_calculation_pattern, :integer, default: 0, null: false
  end
end
