FactoryGirl.define do
  factory :spend_agreement_deal do
    association :deal
    association :spend_agreement
  end
end
