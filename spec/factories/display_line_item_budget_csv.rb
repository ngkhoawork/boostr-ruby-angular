FactoryGirl.define do
  factory :display_line_item_budget_csv do
    company_id nil
    line_number '1'
    budget 10_000
    month_and_year '01-2017'
    impressions 300
    revenue_calculation_pattern 0
  end
end
