FactoryGirl.define do
  factory :company do
    name { FFaker::Company.name }

    after(:build) do |item| 
      def item.setup_defaults; true; end
    end

    after(:create) do |item|
      create :field, :client_type_field, company: item
    end
  end

  factory :company_with_defaults, class: Company do
    after(:build) do |item|
      def item.setup_defaults; super; end
    end
  end
end # Factory defina
