class BillingSummary::IosForMissingDisplayLineItemsSerializer < ActiveModel::Serializer
  attributes :id, :name, :advertiser_name, :agency_name, :curr_cd, :billing_contact_name, :billing_contact_id,
             :details

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
    @_billing_contacts ||= object.deal.ordered_by_created_at_billing_contacts
  end

  def details
    'missing expected line items from Ad Server'
  end
end
