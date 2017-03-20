FactoryGirl.define do
  factory :io do
    sequence(:name) { |n| "Io name_#{n}" }
    budget 100
    start_date "2016-09-28 15:15:19"
    end_date "2016-09-28 15:15:19"
    external_io_number 1
    io_number 1
  end
end
