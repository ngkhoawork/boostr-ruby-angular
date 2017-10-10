FactoryGirl.define do
  factory :account_dimension do
    name FFaker::Lorem.phrase
    trait :advertiser do
      account_type 10
    end

    trait :agency do
      account_type 11
    end
  end

  factory :advertiser_account_dimension, traits: [:advertiser]
  factory :agency_account_dimension, traits: [:agency]

  factory :account_with_related_advertisers, traits: [:agency] do
    after_create do |agency|
      advertiser = advertiser_account_dimension
      agency.advertisers << advertiser
    end
  end
end
