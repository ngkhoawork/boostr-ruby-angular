class CustomFieldName < ActiveRecord::Base
  FIELD_LIMITS = {
    currency: 10,
    currency_code: 10,
    text: 10,
    note: 10,
    datetime: 10,
    number: 10,
    number_4_dec: 10,
    integer: 10,
    boolean: 10,
    percentage: 10,
    dropdown: 10,
    sum: 10,
    link: 10
  }.freeze
  SUBJECT_TYPES = connection.tables.map(&:classify).freeze

  belongs_to :company, required: true
  has_many :custom_field_options, -> { order('LOWER(value)') }, dependent: :destroy

  validates :subject_type, inclusion: { in: SUBJECT_TYPES }
  validates :field_type, presence: true, inclusion: { in: FIELD_LIMITS.keys.map(&:to_s) }
  validates :field_label, presence: true
  validates :position, presence: true, uniqueness: true, numericality: true
  validate  :ensure_allowed_number_of_fields_is_not_exceeded

  scope :position_asc, -> { order(position: :asc) }
  scope :active, -> { where('disabled IS NOT TRUE') }
  scope :for_model, ->(model_name) { where(subject_type: model_name) if model_name && check_subject_type!(model_name) }

  before_create :assign_index
  after_create :reset_custom_fields

  accepts_nested_attributes_for :custom_field_options

  def self.check_subject_type!(subject_type)
    SUBJECT_TYPES.include?(subject_type) || (raise 'Unknown subject type')
  end

  def field_name
    "#{field_type}#{field_index}"
  end

  def to_csv_header
    CSV::HeaderConverters[:symbol].call(field_label)
  end

  private

  def ensure_allowed_number_of_fields_is_not_exceeded
    return unless field_type

    if all_records_of_current_field_type.count >= FIELD_LIMITS[field_type.to_sym]
      errors.add(:field_type, "#{field_type.capitalize} reached it's limit of #{FIELD_LIMITS[field_type.to_sym]}")
    end
  end

  def assign_index
    self.field_index = max_existed_index.to_i.next
  end

  def reset_custom_fields
    CustomField.where(subject_type: subject_type, company_id: company_id).update_all(field_name => nil)
  end

  def max_existed_index
    all_records_of_current_field_type.pluck(:field_index).max
  end

  def all_records_of_current_field_type
    self.class.where(subject_type: subject_type, company_id: company_id, field_type: field_type)
  end
end
