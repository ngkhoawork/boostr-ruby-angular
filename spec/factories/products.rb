FactoryGirl.define do
  factory :product do
    name { FFaker::Product.name }
  end
end
