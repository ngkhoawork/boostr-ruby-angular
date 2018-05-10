module CustomFieldNameBase
  extend ActiveSupport::Concern

  included do
    validates_presence_of :field_type
    validates_uniqueness_of :position, scope: :company_id
    validates_numericality_of :position
    validate :amount_of_custom_fields_by_field_type

    before_create :assign_index

    after_create :remove_custom_fields_values
  end

  INDEX_FOR_FIRST_CF = 1

  def field_name
    field_type + field_index.to_s
  end

  def underscored_field_label
    field_label.parameterize.underscore
  end

  def to_csv_header
    CSV::HeaderConverters[:symbol].call(field_label)
  end

  private

  def assign_index
    self.field_index = free_index
  end

  def remove_custom_fields_values
    raise 'Should be implemented in the delivered class'
  end

  def free_index
    existed_indexes = custom_field_names_by_field_type.pluck(:field_index)
    (INDEX_FOR_FIRST_CF..field_limit).to_set.difference(existed_indexes).min
  end

  def amount_of_custom_fields_by_field_type
    return if field_limit_absent? || field_limit > custom_field_names_by_field_type.count
    errors.add(:field_type, "#{field_type.capitalize} reached it's limit of #{field_limit}")
  end

  def custom_field_names_by_field_type
    raise 'Should be implemented in the delivered class'
  end

  def field_limit
    self.class::FIELD_LIMITS[field_type.to_sym]
  end

  def field_limit_absent?
    field_type.blank? || field_limit.blank?
  end
end
