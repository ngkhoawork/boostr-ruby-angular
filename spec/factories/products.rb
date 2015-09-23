FactoryGirl.define do
  factory :product do
    name { FFaker::Product.product_name }
    product_line 'Desktop'
    family 'Video'
    pricing_type 'CPC'
  end
end
