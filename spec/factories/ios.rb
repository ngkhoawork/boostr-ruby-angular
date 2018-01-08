FactoryBot.define do
  factory :io do
    sequence(:name) { |n| "Io name_#{n}" }
    deal
    budget 100
    start_date "2016-09-28 15:15:19"
    end_date "2016-09-28 15:15:19"
    association :advertiser, factory: :client
    association :agency, factory: :client
    external_io_number { rand(1000..9999) }
    io_number { rand(1000..9999) }
  end
end
