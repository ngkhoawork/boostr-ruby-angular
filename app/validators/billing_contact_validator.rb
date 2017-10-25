class BillingContactValidator < ActiveModel::Validator

  REQUIRED_ADDRESS_FIELDS = [:street1, :city, :country, :zip, :state]

  def validate(record)
    @record = record
    if billing_validation_turned_on? && !contact_address_is_valid? && is_billing?
      record.errors.add(:billing_address, 'Deal contact requires full address')
    end
  end

  private

  attr_reader :record

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
    contact.company
  end
end