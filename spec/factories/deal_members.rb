FactoryGirl.define do
  factory :deal_member do
    share { rand(100) }
    role 'Member'
    user
    deal
  end
end
