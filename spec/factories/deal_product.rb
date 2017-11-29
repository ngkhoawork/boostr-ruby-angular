FactoryGirl.define do
  factory :deal_product do
    budget 999
    budget_loc 999
    
    association :deal, factory: :deal
    association :product, factory: :product
  end
end
