FactoryGirl.define do
  factory :deal_product do
    start_date '2015-01-01'
    end_date '2015-01-31'
    budget 3_100_000
    deal
    product
  end
end
