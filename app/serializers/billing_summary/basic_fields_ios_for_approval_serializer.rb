class BillingSummary::BasicFieldsIosForApprovalSerializer < ActiveModel::Serializer
  attributes :io_id, :io_number, :io_name, :advertiser_name, :agency_name, :currency, :billing_contact_name,
             :product_name, :product, :revenue_type, :vat, :currency_symbol, :billing_contact_email, :street1, :city,
             :state, :country, :postal_code

  def io_number
    io&.io_number
  end

  def io_name
    io&.name
  end

  def io_id
    io&.id
  end

  def advertiser_name
    advertiser&.name
  end

  def agency_name
    agency&.name
  end

  def currency
    io.curr_cd
  end

  def currency_symbol
    io.currency.curr_symbol
  end

  def billing_contact_name
    billing_contact&.contact&.name
  end

  def product_name
    product&.name
  end

  def revenue_type
    product&.revenue_type
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

  private

  def address
    @_address ||= billing_contact.contact.address
  end

  def billing_contact_present?
    @_billing_contact_present ||= billing_contact.present?
  end

  def calculate_vat
    object.budget_loc.to_f * 20 / 100 if country.eql?('United Kingdom') if billing_contact_present?
  end
end
