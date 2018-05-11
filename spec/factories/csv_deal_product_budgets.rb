FactoryGirl.define do
  factory :csv_deal_product_budget, class: Csv::DealProductBudget do
    transient do
      deal nil
      product nil
      company nil
    end

    deal_id { deal&.id }
    deal_name { deal&.name }
    product_name { product&.name }
    product_level1 nil
    product_level2 nil
    budget { rand(1000..9999) }
    start_date '01/01/2018'
    end_date '01/31/2018'
    company_id { company&.id }
  end
end
