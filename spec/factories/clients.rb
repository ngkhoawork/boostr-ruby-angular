FactoryGirl.define do
  factory :client do
    sequence(:name) { |n| "Client#{n} " + FFaker::Company.name }
    website { FFaker::Internet.http_url }
    address
    association :parent_client, factory: :parent_client

    before(:create) do |item|
      item.company = Company.first if item.company.nil?

      if item.client_type_id.nil?
        item.client_type_id = item.company
                                     .fields
                                     .find_by(name: 'Client Type')
                                     .options.ids.sample
      end
    end

    trait :advertiser do
      before(:create) do |client|
        client.client_type_id = Field.find_by(company_id: client.company_id, name: 'Client Type')
                                     .options.find_by('options.name = ?', 'Advertiser').id
      end
    end

    trait :agency do
      before(:create) do |client|
        client.client_type_id = Field.find_by(company_id: client.company_id, name: 'Client Type')
                                     .options.find_by('options.name = ?', 'Agency').id
      end
    end

    factory :parent_client do
      parent_client nil
    end

    factory :bare_client do
      parent_client nil
      website nil
      address nil
    end
  end
end
