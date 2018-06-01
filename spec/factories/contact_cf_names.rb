FactoryGirl.define do
  factory :contact_cf_name do
    company
    field_type 'text'
    sequence(:position) { |n| n }

    after(:create) do |item|
      create(:contact_cf_option, contact_cf_name: item)
    end
  end
end
