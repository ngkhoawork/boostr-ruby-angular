class CustomFieldNames::Serializer < ActiveModel::Serializer
  attributes :id,
             :subject_type,
             :company_id,
             :field_index,
             :field_type,
             :field_label,
             :is_required,
             :position,
             :show_on_modal,
             :disabled,
             :created_at,
             :updated_at
end
