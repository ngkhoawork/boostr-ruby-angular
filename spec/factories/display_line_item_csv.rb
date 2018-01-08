FactoryBot.define do
  factory :display_line_item_csv do
    io_name 'test_123'
    external_io_number '1'
    line_number '2'
    ad_server 'O1'
    start_date '2017-01-01'
    end_date '2017-02-01'
    product_name 'Display'
    quantity '1000'
    price '100'
    pricing_type 'PPC'
    budget '100000'
    budget_delivered '1500'
    quantity_delivered '50'
    quantity_delivered_3p '60'
  end
end
