FactoryGirl.define do
  factory :ssp_advertiser do
    name { FFaker::Product.product_name }
    client
    ssp

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
