FactoryGirl.define do
  factory :io do
    name { FFaker::Product.product_name }
    deal
    association :advertiser, factory: :client
    association :agency, factory: :client
    budget 1
    start_date "2016-09-28 15:15:19"
    end_date "2016-10-28 15:15:19"
    external_io_number { rand(1000..9999) }
    io_number { rand(1000..9999) }
  end
end
