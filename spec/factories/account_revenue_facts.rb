FactoryGirl.define do
  factory :account_revenue_fact do
    company_id 1
    account_dimension_id 1
    time_dimension_id 1
    category_id 1
    subcategory_id 1
    revenue_amount 10_000
  end
end