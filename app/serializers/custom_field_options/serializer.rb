class CustomFieldOptions::Serializer < ActiveModel::Serializer
  attributes :id,
             :custom_field_name_id,
             :value,
             :created_at,
             :updated_at
end
