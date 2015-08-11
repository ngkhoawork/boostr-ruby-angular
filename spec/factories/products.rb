FactoryGirl.define do
  factory :product do
    name { FFaker::Product.product_name }
    product_line { %w(Desktop Phone Tablet).sample }
    family { %w(Video Native Banner).sample }
    pricing_type { %w(CPM CPC CPE).sample }
  end
end
