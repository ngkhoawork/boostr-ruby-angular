FactoryGirl.define do
  factory :time_period do
    sequence(:name) { |n| "Q#{n}" }
    start_date "2015-01-01"
    end_date "2015-03-31"
  end
end
