FactoryGirl.define do
  factory :spend_agreement_parent_company do
    spend_agreement
    association :parent_company, factory: :client
  end
end
