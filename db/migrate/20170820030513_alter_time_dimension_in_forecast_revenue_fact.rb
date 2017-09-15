class AlterTimeDimensionInForecastRevenueFact < ActiveRecord::Migration
  def change
  	ForecastRevenueFact.destroy_all
  	remove_column :forecast_revenue_facts, :time_dimension_id
  	add_reference :forecast_revenue_facts, :forecast_time_dimension, index: true
  	add_index :forecast_revenue_facts, [:forecast_time_dimension_id, :user_dimension_id, :product_dimension_id], name: 'forecast_revenue_facts_full_index'
  end
end
