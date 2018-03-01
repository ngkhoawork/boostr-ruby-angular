FactoryGirl.define do
  factory :csv_io_cost, class: Csv::IoCost do
    transient do
      io nil
      product nil
      company nil
    end

    io_number { io&.io_number }
    product_name { product&.name }
    amount { rand(1000..9999) }
    month '2018/01'
    company_id { company&.id }

    after(:create) do |item|
      field = item.company.fields.find_by(subject_type: 'Cost', name: 'Cost Type')
      field.options.create(name: 'test')
    end
  end
end
