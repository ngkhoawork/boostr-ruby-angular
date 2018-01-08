FactoryBot.define do
  factory :display_line_item do
    io nil
    line_number { rand(1..99) }
    ad_server "MyString"
    quantity 1
    budget ""
    pricing_type "MyString"
    product nil
    budget_delivered ""
    budget_remaining ""
    quantity_delivered 1
    quantity_remaining 1
    start_date "2016-11-01"
    end_date "2016-11-01"
    daily_run_rate 1
    num_days_til_out_of_budget ""
    quantity_delivered_3p 1
    quantity_remaining_3p 1
    budget_delivered_3p ""
    budget_remaining_3p ""
  end

end
