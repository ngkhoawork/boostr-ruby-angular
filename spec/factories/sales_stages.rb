FactoryBot.define do
  factory :sales_stage do
    company
    name { FFaker::Lorem.phrase }
    position { rand(1..10) }
    probability { rand(0..100) }
  end
end
