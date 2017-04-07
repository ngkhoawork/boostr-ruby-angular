class BillingSummary::BasicFieldsIosForApprovalSerializer < ActiveModel::Serializer
  attributes :io_number, :io_name, :advertiser_name, :agency_name, :currency, :billing_contact_name, :product_name,
             :revenue_type, :vat, :currency_symbol, :billing_contact_email, :street1, :city, :state, :country,
             :postal_code, :billing_instructions

  def io_number
    io.io_number
  end

  def io_name
    io.name
  end

  def advertiser_name
    advertiser.name if advertiser.present?
  end

  def agency_name
    agency.name if agency.present?
  end

  def currency
    io.curr_cd
  end

  def currency_symbol
    io.currency.curr_symbol
  end

  def billing_contact_name
    billing_contact.contact.name if billing_contact_present?
  end

  def product_name
    product.name
  end

  def revenue_type
    product.revenue_type
  end

  def vat
    calculate_vat
  end

  def billing_contact_email
    address.email if billing_contact_present?
  end

  def street1
    address.street1 if billing_contact_present?
  end

  def city
    address.city if billing_contact_present?
  end

  def state
    address.state if billing_contact_present?
  end

  def country
    address.country if billing_contact_present?
  end

  def postal_code
    address.zip if billing_contact_present?
  end

  def billing_instructions
    if deal_custom_field_names.present? && deal.deal_custom_field.present?
      deal.deal_custom_field.send(deal_custom_field_type)
    end
  end

  private

  def address
    @_address ||= billing_contact.contact.address
  end

  def billing_contact_present?
    @_billing_contact_present ||= billing_contact.present?
  end

  def deal
    @_deal ||= io.deal
  end

  def deal_custom_field_names
    @_deal_custom_field_names ||= deal.company.deal_custom_field_names.find_by(field_label: 'Billing Instructions')
  end

  def deal_custom_field_type
    "#{deal_custom_field_names.field_type}#{deal_custom_field_names.field_index}"
  end
end
