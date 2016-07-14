FactoryGirl.define do
  factory :option do
    name "Test Campaign"

    before(:create) do |item|
      item.company = Company.first
    end
  end
end
