FactoryGirl.define do
  factory :contact do
    name { FFaker::Name.name }
    position { FFaker::Job.title }
    client
    address
  end
end
