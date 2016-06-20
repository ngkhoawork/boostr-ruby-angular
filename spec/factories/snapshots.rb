FactoryGirl.define do
  factory :snapshot do
    before(:create) do |item|
      item.company = Company.first
    end
  end
end
