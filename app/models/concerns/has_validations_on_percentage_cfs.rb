module HasValidationsOnPercentageCfs
  extend ActiveSupport::Concern

  included do
    validate :percentage_validations

    private

    class << self
      def percentage_column_names
        column_names.grep(/percentage/)
      end

      def custom_field_names_assoc
        raise NotImplementedError, __method__
      end
    end
  end

  def field_label(column)
    cf_name_assoc(column)&.field_label
  end

  private

  delegate :percentage_column_names, :custom_field_names_assoc, to: :class

  def percentage_validations
    percentage_column_names.each do |column_name|
      next unless public_send(column_name) && cf_name_assoc(column_name)

      validate_numeric_kind(column_name)
      validate_range_inclusion(column_name)
    end
  end

  def validate_numeric_kind(column_name)
    if read_attribute_before_type_cast(column_name).to_s =~ /\A[0-9]+(?:\.[0-9]+)?\z/
      true
    else
      errors.add(field_label(column_name), 'must be a number')
      false
    end
  end

  def validate_range_inclusion(column_name)
    if (0..100).include?(read_attribute_before_type_cast(column_name).to_i)
      true
    else
      errors.add(field_label(column_name), 'must be in 0-100 range')
      false
    end
  end

  def cf_name_assoc(attribute_name)
    column_name = attribute_name.downcase

    public_send(custom_field_names_assoc)
      .by_type(column_type(column_name))
      .by_index(column_index(column_name))
      .first
  end

  def column_type(column_name)
    column_name.to_s.match(/\A[A-z]+(?=[0-9])/)&.[](0) || (raise 'Inconsistent column type')
  end

  def column_index(column_name)
    column_name.to_s.match(/(?<=[A-z])[0-9]+\z/)&.[](0) || (raise 'Inconsistent column index')
  end
end
