FactoryGirl.define do
  factory :time_dimension do
    name { FFaker::BaconIpsum.word }
    start_date { Date.today }
    end_date { Date.today + 1.day }
    days_length 1
  end
end
