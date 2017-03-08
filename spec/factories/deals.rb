FactoryGirl.define do
  factory :deal do
    start_date Date.new(2015, 7, 29)
    end_date Date.new(2015, 8, 29)
    sequence(:name) { |n| "Deal #{n}" }
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

    factory :deal_with_contacts do
      transient do
        contacts_count 3
      end

      after(:create) do |deal, evaluator|
        create_list(:contact, evaluator.contacts_count, deals: [deal])
      end
    end
  end
end
