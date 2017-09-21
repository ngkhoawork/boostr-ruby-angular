class AddIndexToForecastFactTables < ActiveRecord::Migration
  def change
  	add_index :forecast_revenue_facts, [:time_dimension_id, :user_dimension_id, :product_dimension_id], name: 'forecast_revenue_facts_full_index'
  	add_index :forecast_pipeline_facts, [:time_dimension_id, :user_dimension_id, :product_dimension_id, :stage_dimension_id], name: 'forecast_pipeline_facts_full_index'
  end
end
