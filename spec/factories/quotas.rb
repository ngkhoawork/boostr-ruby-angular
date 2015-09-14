FactoryGirl.define do
  factory :quota do
    value 10000
    user
    company
  end
end
