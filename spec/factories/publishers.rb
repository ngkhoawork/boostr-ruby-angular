FactoryGirl.define do
  factory :publisher do
    client
    name { FFaker::Company.name }
    website { FFaker::Internet.uri('https') }
    comscore true

    after(:create) do |publisher|
      create(:address, addressable: publisher)
    end

    factory :publisher_with_assets do
      transient do
        assets_count 3
      end

      after(:create) do |publisher, evaluator|
        create_list(:asset, evaluator.assets_count, attachable: publisher)
      end
    end
  end
end
