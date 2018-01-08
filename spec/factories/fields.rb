FactoryBot.define do
  factory :field do
    subject_type "Deal"
    value_type "Option"
    name "Deal Type"

    before(:create) do |item|
      item.company = Company.first
    end
  end
end
