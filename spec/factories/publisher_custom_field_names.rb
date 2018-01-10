FactoryGirl.define do
  factory :publisher_custom_field_name do
    company

    field_index 1
    field_type 'note'
    sequence(:field_label) { |n| "Test #{n}" }
    sequence(:position) { |n| n }
  end
end
