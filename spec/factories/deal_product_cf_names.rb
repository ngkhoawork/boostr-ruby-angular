FactoryGirl.define do
  factory :deal_product_cf_name do
    company nil
    field_index 1
    field_type 'text'
    field_label 'Owner'
    is_required false
    sequence(:position) { |n| n }
    show_on_modal false
    disabled false
  end
end
