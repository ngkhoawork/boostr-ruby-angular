FactoryGirl.define do
  factory :spend_agreement_client do
    association :client
    association :spend_agreement
  end
end
