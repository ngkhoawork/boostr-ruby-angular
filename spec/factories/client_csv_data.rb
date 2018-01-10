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
    region nil
    segment nil
    holding_company nil
    company_id nil

    initialize_with { attributes }

    after(:build) do |item|
      setup_default_client_csv_data(item)
    end

    factory :client_csv_data_custom_fields do
      after(:build) do |item|
        setup_custom_fields(item)
      end
    end
  end
end

def setup_default_client_csv_data(item)
  if item[:parent].nil?
    item[:parent] = Company.find(item[:company_id]).clients.first.name
  end

  if item[:category].nil?
    category = Company.find(item[:company_id]).fields.where(name: 'Category').first.options.first
    item[:category] = category.name
  end

  if item[:subcategory].nil? && category
    subcategory = category.suboptions.first
    item[:subcategory] = subcategory.name
  end

  if item[:teammembers].nil?
    user = Company.find(item[:company_id]).users.first
    item[:teammembers] = user.email + '/100'
  end
end

def setup_custom_fields(item)
  item[:custom_field_names].each do |cf|
    item[cf.to_csv_header] = case cf.field_type
    when 'boolean'
      [true, false].sample
    when 'datetime'
      FFaker::Time.date
    when 'number'
      max = 999
      min = 100
      (rand * (max - min) + min).round(1)
    when 'text'
      FFaker::BaconIpsum.paragraph
    end
  end
  item[:custom_field_names] = nil
end
