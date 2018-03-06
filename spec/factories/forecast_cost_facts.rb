FactoryGirl.define do
  factory :forecast_cost_fact do
    forecast_time_dimension nil
    user_dimension nil
    product_dimension nil
    amount "9.99"
    monthly_amount ""
  end
end
