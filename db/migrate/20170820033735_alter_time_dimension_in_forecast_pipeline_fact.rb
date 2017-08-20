class AlterTimeDimensionInForecastPipelineFact < ActiveRecord::Migration
  def change
  	ForecastPipelineFact.destroy_all
  	remove_column :forecast_pipeline_facts, :time_dimension_id
  	add_reference :forecast_pipeline_facts, :forecast_time_dimension, index: true
  	add_index :forecast_pipeline_facts, [:forecast_time_dimension_id, :user_dimension_id, :product_dimension_id, :stage_dimension_id], name: 'forecast_pipeline_facts_full_index'
  end
end
