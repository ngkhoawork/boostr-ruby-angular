FactoryGirl.define do
  factory :quota do
    value 10000
    value_type QUOTA_TYPES[:gross]
    user
    time_period

    after(:build) do |item|
      item.company = Company.first unless item.company.present?
    end
    before(:create) do |item|
      item.company = Company.first unless item.company.present?
    end
  end
end
