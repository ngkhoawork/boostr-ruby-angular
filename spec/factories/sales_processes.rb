FactoryGirl.define do
  factory :sales_process do
    sequence(:name) { |n| n.to_s + FFaker::Product.product_name }

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
