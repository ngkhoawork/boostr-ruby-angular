FactoryGirl.define do
  factory :client_member do
    share { rand(1..100) }
    role 'Can Edit'
  end
end
