FactoryGirl.define do
  factory :deal do
    start_date Date.new(2015, 7, 29)
    end_date Date.new(2015, 8, 29)
    sequence(:name) { |n| "Deal #{n}" }
    stage
    next_steps 'Call Somebody'
    association :advertiser, factory: :client
    association :agency, factory: :client
  end
end
