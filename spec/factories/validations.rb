FactoryGirl.define do
  factory :validation do
    company { Company.first }
    factor { FFaker::HipsterIpsum.phrase }
    value_type 'Number'
    association :criterion, factory: :value
  end
end
