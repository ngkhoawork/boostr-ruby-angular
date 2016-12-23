class Value < ActiveRecord::Base
  # The instance this value is attached to... i.e., client: {name: Nike, id: 10}
  belongs_to :subject, polymorphic: true
  belongs_to :value_object, polymorphic: true
  belongs_to :option
  belongs_to :field
  belongs_to :company

  before_validation :set_value_type, :set_company

  def as_json(options = {})
    super(options.merge(include: [:option], methods: [:value]))
  end

  def value
    return value_text if value_type == 'Text'
    return value_number if value_type == 'Number'
    return value_float if value_type == 'Decimal'
    return value_float if value_type == 'Percent'
    return value_number if value_type == 'Money'
    return value_datetime if value_type == 'Datetime'
    return value_object if value_type == 'Object'
  end

  def value=(value)
    self.value_text = value if value_type == 'Text'
    self.value_number = value if value_type == 'Number'
    self.value_float = value if value_type == 'Decimal'
    self.value_float = value if value_type == 'Percent'
    self.value_number = value if value_type == 'Money'
    self.value_datetime = value if value_type == 'Datetime'
    self.value_object = value if value_type == 'Object'
  end

  protected

  def set_value_type
    self.value_type = self.field.value_type
  end

  def set_company
    self.company = self.field.company
  end
end
