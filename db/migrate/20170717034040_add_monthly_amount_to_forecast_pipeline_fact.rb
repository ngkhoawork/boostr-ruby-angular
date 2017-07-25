class AddMonthlyAmountToForecastPipelineFact < ActiveRecord::Migration
  def change
  	add_column :forecast_pipeline_facts, :monthly_amount, :jsonb, null: false, default: '{}'
    add_index  :forecast_pipeline_facts, :monthly_amount, using: :gin
 		add_column :forecast_pipeline_facts, :probability, :integer
  end
end
