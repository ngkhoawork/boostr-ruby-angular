FactoryGirl.define do
  factory :exchange_rate do
    start_date { Date.today - 1.day }
    end_date { Date.today + 1.month }
    currency
  end
end
