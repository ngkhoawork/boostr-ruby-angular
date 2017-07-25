class ForecastRevenueFact < ActiveRecord::Base
  belongs_to :time_dimension
  belongs_to :user_dimension
  belongs_to :product_dimension
end
