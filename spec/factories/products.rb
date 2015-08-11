FactoryGirl.define do
  factory :product do
    name { FFaker::Product.product_name }
  end
end
