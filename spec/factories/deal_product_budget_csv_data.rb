FactoryBot.define do
  factory :deal_product_budget_csv_data, class: Hash do
    deal_id nil
    deal_name nil
    deal_product nil
    budget 10000.0
    period 'Jul-15'

    initialize_with { attributes }

    after(:build) do |item|
      if item[:deal_name].nil?
        item[:deal_name] = Company.first.deals.order(:id).first.name
      end

      if item[:deal_product].nil?
        item[:deal_product] = Company.first.products.sample.name
      end
    end
  end
end