FactoryGirl.define do
  factory :client do
    name { FFaker::Company.name }
    website { FFaker::Internet.http_url }
    address
    association :parent_client, factory: :parent_client

    before(:create) do |item|
      item.company = Company.first

      if item.client_type_id.nil?
        item.client_type_id = Company.first.fields.find_by(name: 'Client Type').options.ids.sample
      end
    end

    factory :parent_client do
      parent_client nil
    end
  end
end
