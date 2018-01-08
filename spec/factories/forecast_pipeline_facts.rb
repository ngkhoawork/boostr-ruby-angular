FactoryBot.define do
  factory :forecast_pipeline_fact do
    forecast_time_dimension
		user_dimension
		product_dimension
		stage_dimension
		amount "0.00"
  end
end
