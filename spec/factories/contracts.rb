FactoryGirl.define do
  factory :contract do
    name { FFaker::Lorem.word }
    description { FFaker::BaconIpsum.paragraph }
    start_date { Date.today }
    end_date { Date.today + 10.days }
  end
end
