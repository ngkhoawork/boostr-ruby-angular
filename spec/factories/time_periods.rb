FactoryGirl.define do
  factory :time_period do
    sequence(:name) { |n| "Q#{n}" }
    start_date "2015-01-01"
    end_date "2015-03-31"

    after(:build) do |item|
      item.company = Company.first unless item.company.present?
    end

    before(:create) do |item|
      item.company = Company.first unless item.company.present?
    end
  end
end
