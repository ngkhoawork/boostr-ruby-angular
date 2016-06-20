FactoryGirl.define do
  factory :stage do
    name 'Prospect'
    probability 10
    open true
    active true
    color '#ffe630'

    before(:create) do |item|
      item.company = Company.first
    end
  end
end
