class DealCustomFieldName < ActiveRecord::Base
  belongs_to :company
  has_many :deal_custom_field_options, dependent: :destroy

  has_one :ealert_custom_field, as: :subject, dependent: :destroy

  accepts_nested_attributes_for :deal_custom_field_options

  scope :by_type, -> type { where(field_type: type) if type.present? }
  scope :by_index, -> field_index { where(field_index: field_index) if field_index.present? }

  after_create do
    company.deal_custom_fields.update_all(field_name => nil)
  end

  def self.get_field_limit(type)
    field_limits = {
      "currency" => 7,
      "text" => 5,
      "note" => 2,
      "datetime" => 7,
      "number" => 7,
      "number_4_dec" => 7,
      "integer" => 7,
      "boolean" => 3,
      "percentage" => 5,
      "dropdown" => 7,
      "sum" => 7,
      "link" => 7
    }
    field_limits[type]
  end

  def field_name
    field_type + field_index.to_s
  end

  def to_csv_header
    CSV::HeaderConverters[:symbol].call(field_label)
  end
end
