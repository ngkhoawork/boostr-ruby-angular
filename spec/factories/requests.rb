FactoryBot.define do
  factory :request do
    association :requester, factory: :user
    association :assignee, factory: :user
    deal
    description { FFaker::HipsterIpsum.phrase }
    resolution { FFaker::HipsterIpsum.phrase }
    due_date { FFaker::Time.date }
    status { ['New', 'Denied', 'Completed'].sample }
    request_type { ['Revenue'].sample }

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end

end
