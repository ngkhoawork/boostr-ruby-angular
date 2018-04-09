FactoryGirl.define do
  factory :pmp do
    sequence(:name) { |n| "Pmp#{n} " + FFaker::Product.product_name }
    start_date Date.new(2015, 7, 29)
    end_date Date.new(2015, 8, 29)
    curr_cd 'USD'
    association :advertiser, factory: :client
    association :agency, factory: :client
    deal

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
