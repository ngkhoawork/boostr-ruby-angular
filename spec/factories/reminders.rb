FactoryGirl.define do
  factory :reminder do
    name { FFaker::HipsterIpsum.word }
    comment { FFaker::HipsterIpsum.sentence }
    remind_on { FFaker::Time.date }
  end
end
