FactoryGirl.define do
  factory :csv_client, class: Csv::Client do
    company_id nil
    name { FFaker::Company.name }
    type { %w{advertiser agency}.sample }
    parent_account nil
    category nil
    teammembers nil
    replace_team nil
    region nil
    segment nil
    holding_company nil
    address { FFaker::AddressUS.street_address }
    city    { FFaker::AddressUS.city }
    state   { FFaker::AddressUS.state_abbr }
    zip     { FFaker::AddressUS.zip_code }
    country { ISO3166::Country.all_translated.sample }
    phone   { FFaker::PhoneNumber.phone_number }
    website { FFaker::Internet.http_url }
    unmatched_fields { Hash.new }
    company_fields nil

    factory :csv_client_with_custom_fields do
      after(:build) do |item|
        setup_client_csv_custom_fields(item)
      end
    end
  end
end

def setup_client_csv_custom_fields(item)
  item.custom_field_names.each do |cf|
    value = case cf.field_type
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

    item.unmatched_fields[cf.to_csv_header] = value
  end
  item.custom_field_names = nil
end
