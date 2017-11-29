FactoryGirl.define do
  factory :deal_member do
    share { rand(100) }
    
    association :user, factory: :user
    association :deal, factory: :deal
  end
end
