FactoryGirl.define do
  factory :deal do
    start_date Date.new(2015, 7, 29)
    end_date Date.new(2015, 8, 29)
    sequence(:name) { |n| "Deal #{n} " + FFaker::NatoAlphabet.callsign }
    stage
    next_steps 'Call Somebody'
    association :advertiser, factory: :client
    association :agency, factory: :client

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end

    factory :deal_with_assets do
      transient do
        assets_count 3
      end

      after(:create) do |deal, evaluator|
        create_list(:asset, evaluator.assets_count, attachable: deal)
      end
    end

    factory :deal_with_deal_max_share_member do
      after(:create) do |deal|
        create(:deal_member, deal: deal, share: 100)
      end
    end

    trait :with_max_share_member do
      after(:create) do |deal|
        create(:deal_member, deal: deal, share: 100)
      end
    end

    trait :with_min_share_member do
      after(:create) do |deal|
        create(:deal_member, deal: deal, share: 0)
      end
    end

    factory :deal_with_contacts do
      transient do
        contacts_count 3
      end

      after(:create) do |deal, evaluator|
        create_list(:contact, evaluator.contacts_count, deals: [deal], company: deal.company)
      end
    end
  end
end
