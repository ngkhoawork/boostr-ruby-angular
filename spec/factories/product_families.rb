FactoryGirl.define do
  factory :product_family do
    name { FFaker::Product.product_name }

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
