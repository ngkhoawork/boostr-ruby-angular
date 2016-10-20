FactoryGirl.define do
  factory :client_csv_data, class: Hash do
    id nil
    name { FFaker::Company.name }
    type { ['Agency', 'Advertiser'].sample }
    parent nil
    category nil
    subcategory nil
    address { FFaker::AddressUS.street_address }
    city { FFaker::AddressUS.city }
    state { FFaker::AddressUS.state_abbr }
    zip { FFaker::AddressUS.zip_code }
    phone { FFaker::PhoneNumber.phone_number }
    website { FFaker::Internet.http_url }
    replace_team 'N'
    teammembers nil
    shares nil

    initialize_with { attributes }

    after(:build) do |item|
      if item[:parent].nil?
        item[:parent] = Company.first.clients.first.name
      end

      if item[:category].nil?
        category = Company.first.fields.where(name: 'Category').first.options.first
        item[:category] = category.name
      end

      if item[:subcategory].nil? && category
        subcategory = category.suboptions.first
        item[:subcategory] = subcategory.name
      end

      if item[:teammembers].nil?
        user = Company.first.users.first
        item[:teammembers] = user.email
      end

      if item[:shares].nil?
        item[:shares] = 100
      end
    end
  end
end
