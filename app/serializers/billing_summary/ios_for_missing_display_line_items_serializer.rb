class BillingSummary::IosForMissingDisplayLineItemsSerializer < ActiveModel::Serializer
  attributes :io_number, :name, :advertiser_name, :agency_name, :currency, :billing_contact_name, :billing_contact_id,
             :details, :seller_name

  def seller_name
    object.highest_member.user.name if object.highest_member.present?
  end

  def advertiser_name
    object.advertiser.name if object.advertiser.present?
  end

  def agency_name
    object.agency.name if object.agency.present?
  end

  def billing_contact_name
    billing_contacts.first.contact.name if billing_contacts.any?
  end

  def billing_contact_id
    billing_contacts.first.contact.id if billing_contacts.any?
  end

  def billing_contacts
    @_billing_contacts ||= object.deal.ordered_by_created_at_billing_contacts if object.deal.present?
  end

  def currency
    object.curr_cd
  end

  def details
    'missing expected line items from Ad Server'
  end
end
