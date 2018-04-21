FactoryGirl.define do
  factory :product do
    name { FFaker::Product.product_name }
    revenue_type 'Content-Fee'

    before(:create) do |item|
      item.full_name ||= item.name
      item.company = Company.first if item.company.blank?
    end
  end
end
