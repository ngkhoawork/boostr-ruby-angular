FactoryGirl.define do
  factory :reminder do
    name { FFaker::HipsterIpsum.word }
    comment { FFaker::HipsterIpsum.sentence }
    remind_on { Time.zone.now + 1.hour }
    completed false
    assigned false
  end
end
