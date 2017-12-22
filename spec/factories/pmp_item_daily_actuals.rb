FactoryGirl.define do
  factory :pmp_item_daily_actual do
  	date Date.new(2015, 7, 29)
    price 999.99
    revenue_loc 999.99
    impressions 99
    bids 99
    ad_unit FFaker::Lorem.word
    association :pmp_item, factory: :pmp_item
  end
end
