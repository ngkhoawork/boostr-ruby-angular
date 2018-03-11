FactoryGirl.define do
  factory :company do
    name { FFaker::Company.name }

    after(:build) do |item| 
      class << item
        def setup_defaults; true; end
      end
    end

    trait :setup_defaults do
      after(:build) do |item|
        class << item
          def setup_defaults; super; end
        end
      end
    end
  end # factory
end # Factory defina
