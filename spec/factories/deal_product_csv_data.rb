FactoryGirl.define do
  factory :deal_product_csv_data, class: Hash do
    deal_id nil
    deal_name nil
    product nil
    product_level1 nil
    product_level2 nil
    budget 10000.0

    initialize_with { attributes }

    after(:build) do |item|
      setup_default_deal_product_csv_data(item)
    end

    factory :deal_product_csv_data_custom_fields do
      after(:build) do |item|
        item[:company] = Company.first unless item[:company].present?
        setup_custom_fields(item)
      end
    end
  end
end

def setup_default_deal_product_csv_data(item)
  if item[:deal_name].nil?
    item[:deal_name] = item[:company].deals.order(:id).first.name
  end

  if item[:product].nil?
    item[:product] = item[:company].products.sample.name
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
      (rand * (max - min) + min).round(2)
    when 'text'
      FFaker::BaconIpsum.paragraph
    end
  end
  item[:custom_field_names] = nil
end
