FactoryGirl.define do
  factory :forecast_revenue_fact do
    forecast_time_dimension
    user_dimension
    product_dimension
    amount "9.99"
    monthly_amount ""
  end
end
