class DealProductCfName < ActiveRecord::Base
  include CustomFieldNameBase

  belongs_to :company
  has_many :deal_product_cf_options, -> { order 'LOWER(value)' }, dependent: :destroy
  has_one :ealert_custom_field, as: :subject, dependent: :destroy

  accepts_nested_attributes_for :deal_product_cf_options

  scope :by_type, -> (type) { where(field_type: type) if type.present? }
  scope :by_index, -> (field_index) { where(field_index: field_index) if field_index.present? }
  scope :position_asc, -> { order('position asc') }
  scope :active, -> { where('disabled IS NOT TRUE') }

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
    dropdown:     10,
    sum:          10,
    link:         10
  }

  private

  def remove_custom_fields_values
    company.deal_product_cfs.update_all(field_name => nil)
  end

  def custom_field_names_by_field_type
    company.deal_product_cf_names.by_type(field_type)
  end
end
