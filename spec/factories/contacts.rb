FactoryGirl.define do
  factory :contact do
    name { FFaker::Name.name }
    position { FFaker::Job.title }
  end
end
