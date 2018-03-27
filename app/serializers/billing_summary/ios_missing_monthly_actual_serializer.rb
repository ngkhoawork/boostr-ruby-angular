class BillingSummary::IosMissingMonthlyActualSerializer < ActiveModel::Serializer
  attributes :io_id, :io_number, :io_name, :line_number, :advertiser_name, :agency_name, :currency,
             :billing_contact_name, :product_name, :ad_server, :seller_name

  def seller_name
    io.highest_member.user.name if io.highest_member.present?
  end

  def io_number
    io.io_number
  end

  def io_id
    io.id
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
    object.product.name
  end

  private

  def io
    @_io ||= object.io
  end

  def advertiser
    @_advertiser ||= io.advertiser
  end

  def agency
    @_agency ||= io.agency
  end

  def billing_contact
    billing_contacts.find_by(contact: advertiser.contacts) if billing_contacts.present?
  end

  def billing_contacts
    @_billing_contacts ||= io.deal.ordered_by_created_at_billing_contacts if io.deal.present?
  end
end
