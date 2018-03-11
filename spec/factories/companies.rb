FactoryGirl.define do
  factory :company do
    name { FFaker::Company.name }

    trait :fast_create_company do
      after(:build) do |item| 
        class << item
          def setup_defaults; true; end
        end
      end
    end # trait
  end # factory
end # Factory defina
