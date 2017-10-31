class BillingContactValidator
  REQUIRED_ADDRESS_FIELDS = [:street1, :city, :country, :zip, :state]

  def initialize(record)
    @record = record
  end

  def validate
    if address_has_error?
      record.errors.add(:billing_address, 'Deal contact requires full address')
    end
  end

  private

  attr_reader :record

  def address_has_error?
    billing_validation_turned_on? && !contact_address_is_valid? && is_billing?
  end

  def contact_address_is_valid?
    REQUIRED_ADDRESS_FIELDS.each do |field|
      contact_address.errors.add_on_blank(field)
    end
    contact_address.errors.blank?
  end

  def billing_validation_turned_on?
    !!billing_validation.criterion.value_boolean
  end

  def billing_validation
    company.validations.find_by(factor: 'Billing Contact Full Address', value_type: 'Boolean')
  end

  def is_billing?
    record.role == 'Billing'
  end

  def contact_address
    @contact_address ||= record.address
  end

  def contact
    record.contact
  end

  def company
    record.deal.company
  end
end