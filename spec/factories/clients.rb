FactoryGirl.define do
  factory :client do
    name { FFaker::Company.name }
    website { FFaker::Internet.http_url }
    address

    before(:create) do |item|
      item.company = Company.first
    end
  end
end
