class CustomFieldName < ActiveRecord::Base
  FIELD_COLUMN_TYPE_MAP = {
    currency: :decimal,
    number: :decimal,
    percentage: :decimal,
    currency_code: :string,
    text: :string,
    dropdown: :string,
    link: :string,
    integer: :integer,
    sum: :integer,
    note: :note,
    datetime: :datetime,
    number_4_dec: :number_4_dec,
    boolean: :boolean
  }.freeze

  class << self
    def check_subject_type!(subject_type)
      allowed_subject_types.include?(subject_type) || (raise ArgumentError, 'Unknown subject type')
    end

    def allowed_subject_types
      @allowed_subject_types ||= connection.tables.map(&:classify).freeze
    end

    def allowed_field_types
      @allowed_field_types ||= FIELD_COLUMN_TYPE_MAP.keys.map(&:to_s).freeze
    end

    def allowed_column_types
      @allowed_column_types ||= FIELD_COLUMN_TYPE_MAP.values.uniq.map(&:to_s).freeze
    end

    def column_type_limits
      @column_type_limits ||=
        allowed_column_types.each.with_object({}) do |column_type, acc|
          acc[column_type] = column_type_limit(column_type)
        end.freeze
    end

    private

    def column_type_limit(column_type)
      CustomField.column_names.grep(/#{Regexp.escape(column_type)}/).size
    end
  end

  belongs_to :company, required: true
  has_many :custom_field_options, -> { order('LOWER(value)') }, dependent: :destroy

  validates :subject_type, inclusion: { in: allowed_subject_types }
  validates :field_type, presence: true, inclusion: { in: allowed_field_types }
  validates :field_label, presence: true
  validates :position, presence: true, numericality: true
  validate  :ensure_allowed_number_of_fields_is_not_exceeded

  scope :position_asc, -> { order(position: :asc) }
  scope :active, -> { where('disabled IS NOT TRUE') }
  scope :for_model, ->(model_name) { where(subject_type: model_name) if model_name && check_subject_type!(model_name) }

  before_validation :assign_column_type
  before_create :assign_column_index
  after_create :reset_custom_fields
  after_destroy :reset_custom_fields

  delegate :column_type_limits, to: :class

  accepts_nested_attributes_for :custom_field_options

  def field_name
    "#{column_type}#{column_index}"
  end

  def to_csv_header
    CSV::HeaderConverters[:symbol].call(field_label)
  end

  private

  def ensure_allowed_number_of_fields_is_not_exceeded
    return unless column_type

    if all_records_of_current_column_type.count >= column_type_limits[column_type]
      errors.add(:column_type, "#{column_type.capitalize} reached it's limit of #{column_type_limits[column_type]}")
    end
  end

  def assign_column_type
    self.column_type = FIELD_COLUMN_TYPE_MAP[field_type.to_sym] if field_type
  end

  def assign_column_index
    self.column_index = max_existed_index.to_i.next
  end

  def reset_custom_fields
    CustomField.where(subject_type: subject_type, company_id: company_id).update_all(field_name => nil)
  end

  def max_existed_index
    all_records_of_current_column_type.pluck(:column_index).max
  end

  def all_records_of_current_column_type
    self.class.where(subject_type: subject_type, company_id: company_id, column_type: column_type)
  end
end
