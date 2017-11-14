FactoryGirl.define do
  factory :publisher do
    client
    name { FFaker::Company.name }
    website { FFaker::Internet.uri('https') }

    after(:create) do |publisher|
      create(:address, addressable: publisher)
    end
  end
end
