FactoryGirl.define do
  factory :pmp do
    name { FFaker::Product.product_name }
    budget 9999
    budget_loc 9999
    start_date Date.new(2015, 7, 29)
    end_date Date.new(2015, 8, 29)
    curr_cd 'USD'
    association :advertiser, factory: :client
    association :agency, factory: :client
    association :deal, factory: :deal

    before(:create) do |item|
      item.company = Company.first if item.company.blank?
    end
  end
end
