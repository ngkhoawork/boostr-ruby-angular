FactoryGirl.define do
  factory :product do
    name { FFaker::Product.product_name }
    family 'Video'
  end
end
