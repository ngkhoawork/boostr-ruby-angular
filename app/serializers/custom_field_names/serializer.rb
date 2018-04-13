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
             :csv_header

  has_many :custom_field_options, serializer: CustomFieldOptions::Serializer

  private

  def csv_header
    object.to_csv_header
  end
end
