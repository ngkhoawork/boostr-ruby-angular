FactoryGirl.define do
  factory :deal_member do
    share { rand(100) }
    
    user
    deal

    factory :deal_account_manager do
      association :user, factory: :account_manager
    end
  end
end
