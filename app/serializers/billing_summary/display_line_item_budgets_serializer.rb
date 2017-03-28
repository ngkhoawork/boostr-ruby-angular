class BillingSummary::DisplayLineItemBudgetsSerializer < BillingSummary::BasicFieldsIosForApprovalSerializer
  attributes :id, :display_line_item_id, :line, :ad_server, :amount, :billing_status, :ad_server_budget,
             :ad_server_quantity, :quantity

  def display_line_item_id
    display_line_item.id
  end

  def line
    display_line_item.line_number
  end

  def ad_server
    display_line_item.ad_server
  end

  def amount
    object.budget
  end

  def billing_status
    object.billing_status || 'Pending'
  end

  private

  def billing_contact
    billing_contacts.find_by(contact: advertiser.contacts) if billing_contacts.present?
  end

  def billing_contacts
    @_billing_contacts ||= io.deal.ordered_by_created_at_billing_contacts
  end

  def advertiser
    @_advertiser ||= io.advertiser
  end

  def agency
    @_agency ||= io.agency
  end

  def display_line_item
    @_display_line_item ||= object.display_line_item
  end

  def io
    @_io ||= display_line_item.io
  end

  def product
    @_product ||= display_line_item.product
  end

  def calculate_vat
    object.budget * 20 / 100 if [country_agency, country_advertiser].include?('United Kingdom')
  end

  def country_agency
    agency.country if agency.present?
  end

  def country_advertiser
    advertiser.country if advertiser.present?
  end
end
