class PublisherCustomFieldName < ActiveRecord::Base
  include CustomFieldNameBase

  belongs_to :company
  has_many :publisher_custom_field_options, -> { order 'LOWER(value)' }, dependent: :destroy

  accepts_nested_attributes_for :publisher_custom_field_options

  validates :field_label, presence: true

  scope :by_company, -> (id) { where(company_id: id) }
  scope :by_type, -> (type) { where(field_type: type) }
  scope :by_index, -> (field_index) { where(field_index: field_index) }
  scope :order_by_position, -> { order(:position) }

  FIELD_LIMITS = {
    currency:     7,
    text:         5,
    note:         2,
    datetime:     7,
    number:       7,
    number_4_dec: 7,
    integer:      7,
    boolean:      3,
    percentage:   5,
    dropdown:     7,
    sum:          7,
    link:         7
  }

  private

  def remove_custom_fields_values
    company.publisher_custom_fields.update_all(field_name => nil)
  end

  def custom_field_names_by_field_type
    company.publisher_custom_field_names.by_type(field_type)
  end
end
