FactoryGirl.define do
  factory :pmp_item_monthly_actual do
    amount 999
    amount_loc 999
    association :pmp_item, factory: :pmp_item
  end
end
