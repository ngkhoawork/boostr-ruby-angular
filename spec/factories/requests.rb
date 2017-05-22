FactoryGirl.define do
  factory :request do
    association :requester, factory: :user
    association :assignee, factory: :user
    deal
    description { FFaker::HipsterIpsum.phrase }
    resolution { FFaker::HipsterIpsum.phrase }
    due_date { FFaker::Time.date }
    status { ['New', 'Denied', 'Completed'].sample }
  end

end
