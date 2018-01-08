FactoryBot.define do
  factory :deal_contact do
    deal
    contact
    role nil

    factory :billing_deal_contact do
      role 'Billing'
    end
  end
end
