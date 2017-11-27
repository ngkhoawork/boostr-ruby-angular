class PublisherCustomFieldName < ActiveRecord::Base
  belongs_to :company
  has_many :publisher_custom_field_options, -> { order 'LOWER(value)' }, dependent: :destroy

  accepts_nested_attributes_for :publisher_custom_field_options

  validates :field_type, :field_label, :position, presence: true
  validates :position, uniqueness: true, numericality: true
  validate :amount_of_custom_fields_per_type

  before_create :assign_index

  scope :by_company, -> (id) { where(company_id: id) }
  scope :by_type,  -> type { where(field_type: type) }
  scope :order_by_position, -> { order(:position) }

  INDEX_FOR_FIRST_CF = 1
  FIELD_LIMITS = {
    currency: 7,
    text: 5,
    note: 2,
    datetime: 7,
    number: 7,
    number_4_dec: 7,
    integer: 7,
    boolean: 3,
    percentage: 5,
    dropdown: 7,
    sum: 7,
    link: 7
  }

  def fetch_attr_name_for_publisher_custom_field
    "#{field_type}#{field_index}"
  end

  private

  def assign_index
    self.field_index = maximal_existed_index.next rescue INDEX_FOR_FIRST_CF
  end

  def amount_of_custom_fields_per_type
    if publishers_per_field_type.count >= field_limit
      errors.add(:field_type, "#{self.field_type.capitalize} reached it's limit of #{field_limit}")
    end
  end

  def publishers_per_field_type
    PublisherCustomFieldName
      .by_company(company_id)
      .by_type(field_type)
  end

  def maximal_existed_index
    publishers_per_field_type
      .pluck(:field_index)
      .max
  end

  def field_limit
    FIELD_LIMITS[field_type.to_sym]
  end
end
