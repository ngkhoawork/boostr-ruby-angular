FactoryGirl.define do
  factory :publisher_daily_actual do
    date 1.day.ago
    available_impressions 100
    filled_impressions 80
  end
end
