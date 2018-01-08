FactoryBot.define do
  factory :client_member do
    share { rand(100) }
    user
    client
  end
end
