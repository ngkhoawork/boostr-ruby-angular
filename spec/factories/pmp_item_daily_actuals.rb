FactoryGirl.define do
  factory :pmp_item_daily_actual do
  	date Date.new(2015, 7, 29)
    price 999
    revenue 99
    impressions 99
    win_rate 70
    bids 9
    association :pmp_item, factory: :pmp_item
  end
end
