FactoryGirl.define do
  factory :product do
    name { FFaker::Product.product_name }
    family 'Video'
    revenue_type 'Content-Fee'

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
