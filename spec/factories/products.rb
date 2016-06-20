FactoryGirl.define do
  factory :product do
    name { FFaker::Product.product_name }
    family 'Video'

    before(:create) do |item|
      item.company = Company.first
    end
  end
end
