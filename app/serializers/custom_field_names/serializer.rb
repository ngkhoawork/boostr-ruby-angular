class CustomFieldNames::Serializer < ActiveModel::Serializer
  attributes :id,
             :subject_type,
             :company_id,
             :field_type,
             :field_label,
             :field_name,
             :is_required,
             :position,
             :show_on_modal,
             :disabled,
             :created_at,
             :updated_at

  has_many :custom_field_options, serializer: CustomFieldOptions::Serializer
end
