FactoryGirl.define do
  factory :csv_io_content_fee, class: Csv::IoContentFee do
    transient do
      io nil
      product nil
      company nil
    end

    io_number { io&.io_number }
    product_name { product&.name }
    budget { rand(1000..9999) }
    start_date '01/01/2018'
    end_date '01/31/2018'
    company_id { company&.id }
  end
end
