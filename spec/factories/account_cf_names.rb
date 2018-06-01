FactoryGirl.define do
  factory :account_cf_name do
    company nil
    field_index 1
    field_type 'text'
    field_label 'MyString'
    is_required false
    sequence(:position) { |n| n }
    show_on_modal false
    disabled false
  end
end
