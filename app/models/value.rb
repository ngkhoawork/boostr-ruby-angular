class Value < ActiveRecord::Base
  # The instance this value is attached to... i.e., client: {name: Nike, id: 10}
  belongs_to :subject, polymorphic: true
  belongs_to :value_object, polymorphic: true
  belongs_to :option
  belongs_to :field
  belongs_to :company
  belongs_to :validation

  before_validation :set_value_type, :set_company

  scope :by_option_ids, -> (option_ids) { where('values.option_id in (?)', option_ids) unless option_ids.empty? }

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
    return value_boolean if value_type == 'Boolean'
  end

  def value=(value)
    self.value_text = value if value_type == 'Text'
    self.value_number = value if value_type == 'Number'
    self.value_float = value if value_type == 'Decimal'
    self.value_float = value if value_type == 'Percent'
    self.value_number = value if value_type == 'Money'
    self.value_datetime = value if value_type == 'Datetime'
    self.value_object = value if value_type == 'Object'
    self.value_boolean = value if value_type == 'Boolean'
  end

  protected

  def set_value_type
    if field || subject
      self.value_type = (self.field || self.subject).value_type
    end
  end

  def set_company
    if field || subject
      self.company = (self.field || self.subject).company
    end
  end
end
