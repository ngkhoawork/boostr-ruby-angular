FactoryGirl.define do
  factory :contact do
    name { FFaker::Name.name }
    position { FFaker::Job.title }
    client
    address

    before(:create) do |item|
      item.company = Company.first
    end
  end
end
