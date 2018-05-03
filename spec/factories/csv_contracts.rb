FactoryGirl.define do
  factory :csv_contract, class: Csv::Contract do
    transient do
      type_option nil
      company nil
    end

    name { FFaker::Lorem.word }
    type { type_option&.name }
    company_id { company&.id }
  end
end
