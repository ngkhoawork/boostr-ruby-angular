FactoryGirl.define do
  factory :account_dimension do
    id Random.new.rand(100)
    name FFaker::Lorem.phrase
  end
end
