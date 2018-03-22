FactoryGirl.define do
  factory :field do
    subject_type "Deal"
    value_type "Option"
    name "Deal Type"

    before(:create) do |item|
      item.company ||= Company.first
    end

    trait :client_type_field do
      name 'Client Type'
      subject_type 'Client'
      value_type 'Option'
      locked true

      after(:create) do |item|
        create :option, :advertiser_option, field: item, company_id: item.company_id
        create :option, :agency_option, field: item, company_id: item.company_id
      end
    end
  end
end
