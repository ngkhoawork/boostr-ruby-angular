class ForecastPipelineFact < ActiveRecord::Base
  belongs_to :forecast_time_dimension
  belongs_to :user_dimension
  belongs_to :product_dimension
  belongs_to :stage_dimension
end
