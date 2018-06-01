FactoryGirl.define do
  factory :custom_field_name do
    subject_type { CustomFieldName.allowed_subject_types.sample }
    field_type 'text'
    field_label FFaker::HipsterIpsum.word
    is_required false
    position 1
    show_on_modal false
    disabled false

    trait :with_option do
      after(:create) do |record|
        record.custom_field_options.create(value: FFaker::HipsterIpsum.word)
      end
    end
  end
end
