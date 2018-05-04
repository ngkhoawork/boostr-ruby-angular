FactoryGirl.define do
  factory :csv_contract_special_term, class: Csv::ContractSpecialTerm do
    transient do
      name_option nil
      company nil
      contract nil
    end

    contract_name { contract&.name }
    term_name { name_option&.name }
    company_id { company&.id }
  end
end
