FactoryGirl.define do
  factory :option do
    name "Test Campaign"

    before(:create) do |item|
      item.company = Company.first unless item.company_id.present?
    end
  end
end
