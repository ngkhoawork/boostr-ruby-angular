FactoryGirl.define do
  factory :deal_custom_field_name do
    company nil
    field_index 1
    field_type 'sum'
    sequence(:position) { |n| n }
  end
end
