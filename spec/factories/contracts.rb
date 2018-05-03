FactoryGirl.define do
  factory :contract do
    name { FFaker::Lorem.word }
    description { FFaker::BaconIpsum.paragraph }
    start_date { Date.today }
    end_date { Date.today + 10.days }
    days_notice_required { rand(1..10) }
  end
end
