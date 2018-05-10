class ContactCfName < ActiveRecord::Base
  include CustomFieldNameBase

  belongs_to :company, required: true
  has_many   :contact_cf_options, -> { order 'LOWER(value)' }, dependent: :destroy

  validate  :field_type_permitted

  accepts_nested_attributes_for :contact_cf_options

  default_scope { order(position: :asc) }

  scope :for_company, -> (id) { where(company_id: id) }
  scope :by_type,  -> type { where(field_type: type) if type.present? }
  scope :by_index, -> index { where(field_index: index) if index.present? }

  FIELD_LIMITS = {
    currency:     10,
    text:         10,
    note:         10,
    datetime:     10,
    number:       10,
    number_4_dec: 10,
    integer:      10,
    boolean:      10,
    percentage:   10,
    dropdown:     10
  }

  private

  def remove_custom_fields_values
    company.contact_cfs.update_all(field_name => nil)
  end

  def custom_field_names_by_field_type
    company.contact_cf_names.by_type(field_type)
  end

  def field_type_permitted
    return unless field_limit_absent?

    errors.add(:field_type, "#{field_type&.capitalize} is not permitted for Contacts")
  end
end
