FactoryGirl.define do
  factory :deal_product_csv_data, class: Hash do
    deal_id nil
    deal_name nil
    product nil
    budget 10000.0

    initialize_with { attributes }

    after(:build) do |item|
      if item[:deal_name].nil?
        item[:deal_name] = Company.first.deals.order(:id).first.name
      end

      if item[:product].nil?
        item[:product] = Company.first.products.sample.name
      end
    end
  end
end
