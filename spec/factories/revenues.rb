FactoryBot.define do
  factory :revenue do
    budget 30_000
    budget_remaining 15_000
    start_date "2015-01-01"
    end_date "2015-01-30"
    order_number "1"
    line_number "2"
    ad_server "Yahoo"

    before(:create) do |revenue|
      revenue.company = Company.first
    end
  end
end
