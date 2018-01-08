FactoryBot.define do
  factory :publisher_daily_actual do
    currency
    date 1.day.ago
    available_impressions 100
    filled_impressions 80
    total_revenue 1000
    ecpm 50
  end
end
