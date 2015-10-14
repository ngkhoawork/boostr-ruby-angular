FactoryGirl.define do
  factory :client_type do
    sequence(:name) { |n| "Type #{n}" }
  end
end
