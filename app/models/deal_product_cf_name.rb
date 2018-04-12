class DealProductCfName < ActiveRecord::Base
  belongs_to :company
  has_many :deal_product_cf_options, -> { order 'LOWER(value)' }, dependent: :destroy
  has_one :ealert_custom_field, as: :subject, dependent: :destroy

  accepts_nested_attributes_for :deal_product_cf_options

  scope :by_type, -> type { where(field_type: type) if type.present? }
  scope :by_index, -> field_index { where(field_index: field_index) if field_index.present? }
  scope :position_asc, -> { order('position asc') }
  scope :active, -> { where('disabled IS NOT TRUE') }

  after_create do
    self.company.deal_product_cfs.update_all(field_name => nil)
  end

  def self.get_field_limit(type)
    field_limits = {
        "currency" => 10,
        "text" => 10,
        "note" => 10,
        "datetime" => 10,
        "number" => 10,
        "number_4_dec" => 10,
        "integer" => 10,
        "boolean" => 10,
        "percentage" => 10,
        "dropdown" => 10,
        "sum" => 10
    }
    field_limits[type]
  end

  def field_name
    self.field_type + self.field_index.to_s
  end

  def to_csv_header
    CSV::HeaderConverters[:symbol].call(self.field_label)
  end

  def underscored_field_label
    field_label.parameterize.underscore
  end
end
