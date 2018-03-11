FactoryGirl.define do
  factory :validation do
    factor { FFaker::HipsterIpsum.phrase }
    value_type 'Number'
    association :criterion, factory: :value

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
