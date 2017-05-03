class ContactCfNameSerializer < ActiveModel::Serializer
  attributes(
    :id,
    :field_index,
    :field_type,
    :field_label,
    :is_required,
    :position,
    :show_on_modal,
    :disabled
  )

  has_many :contact_cf_options
end
