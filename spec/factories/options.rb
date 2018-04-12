FactoryGirl.define do
  factory :option do
    name "Test Campaign"

    before(:create) do |item|
      item.company = Company.first unless item.company_id.present?
    end

    trait :advertiser_option do
      name 'Advertiser'
      locked true
    end

    trait :agency_option do
      name 'Agency'
      locked true
    end
  end
end
