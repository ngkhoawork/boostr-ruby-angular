FactoryBot.define do
  factory :publisher_member do
    publisher
    user
    owner true
  end
end
