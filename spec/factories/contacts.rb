FactoryGirl.define do
  factory :contact do
    name { FFaker::Name.name }
    position { FFaker::Job.title }
    client
    address

    factory :contact_with_activities do
      activity
    end
  end
end
