class CustomFieldName < ActiveRecord::Base
  belongs_to :company, required: true
  has_many :custom_field_options, -> { order('LOWER(value)') }, dependent: :destroy

  delegate :column_type_limits, to: :class

  validates :subject_type, inclusion: { in: :allowed_subject_types }
  validates :field_type, presence: true, inclusion: { in: :allowed_field_types }
  validates :field_label, presence: true
  validates :position, uniqueness: { scope: [:subject_type, :company],
                                     message: 'Custom field name should be unique' },
                       presence: true, numericality: true
  validate  :ensure_allowed_number_of_fields_is_not_exceeded

  before_validation :assign_column_type
  before_create :assign_column_index
  after_create :reset_custom_fields
  after_destroy :reset_custom_fields

  scope :position_asc, -> { order(position: :asc) }
  scope :active, -> { where('disabled IS NOT TRUE') }
  scope :required, -> { where(is_required: true) }
  scope :optional, -> { where(is_required: false) }
  scope :for_model, ->(model_name) { where(subject_type: valid_subject_type(model_name)) if model_name && check_subject_type!(model_name) }

  accepts_nested_attributes_for :custom_field_options

  FIELD_COLUMN_TYPE_MAP = {
    currency:      :decimal,
    number:        :decimal,
    percentage:    :decimal,
    currency_code: :string,
    text:          :string,
    dropdown:      :string,
    link:          :string,
    integer:       :integer,
    sum:           :integer,
    note:          :note,
    datetime:      :datetime,
    number_4_dec:  :number_4_dec,
    boolean:       :boolean
  }.freeze

  def field_name
    "#{column_type}#{column_index}"
  end

  def to_csv_header
    CSV::HeaderConverters[:symbol].call(field_label)
  end

  def allowed_subject_types
    self.class.allowed_subject_types
  end

  def allowed_field_types
    self.class.allowed_field_types
  end

  class << self
    def check_subject_type!(subject_type)
      valid_subject_type?(subject_type) || (raise ArgumentError, 'Unknown subject type')
    end

    def valid_subject_type?(subject_type)
      if subject_type.kind_of?(Array)
        (allowed_subject_types & subject_type).any?
      else
        allowed_subject_types.include?(subject_type)
      end
    end

    def valid_subject_type(subject_type)
      if subject_type.kind_of?(Array)
        allowed_subject_types & subject_type
      else
        subject_type
      end
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
