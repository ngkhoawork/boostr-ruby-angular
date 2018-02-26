FactoryGirl.define do
  factory :deal_member do
    share { rand(100) }
    
    user
    deal
  end
end
