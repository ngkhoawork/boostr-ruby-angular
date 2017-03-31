class BillingSummary::BasicFieldsIosForApprovalSerializer < ActiveModel::Serializer
  attributes :io_number, :io_name, :advertiser_name, :agency_name, :currency, :billing_contact_name, :product_name,
             :revenue_type, :vat

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

  def billing_contact_name
    billing_contact.contact.name if billing_contact.present?
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
end
