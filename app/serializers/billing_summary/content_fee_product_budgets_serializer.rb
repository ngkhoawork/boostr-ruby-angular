class BillingSummary::ContentFeeProductBudgetsSerializer < BillingSummary::BasicFieldsIosForApprovalSerializer
  attributes :id, :line, :ad_server, :amount, :billing_status, :type

  def line
    content_fee.id
  end

  def ad_server
    ''
  end

  def amount
    object.budget_loc.to_f
  end

  def billing_status
    object.billing_status || 'Pending'
  end

  def type
    'ContentFeeProductBudget'
  end

  private

  def billing_contact
    billing_contacts.find_by(contact: advertiser.contacts) if billing_contacts.present?
  end

  def billing_contacts
    @_billing_contacts ||= io.deal.ordered_by_created_at_billing_contacts if io.deal.present?
  end

  def advertiser
    @_advertiser ||= io.advertiser
  end

  def agency
    @_agency ||= io.agency
  end

  def io
    @_io ||= content_fee.io
  end

  def content_fee
    @_content_fee ||= object.content_fee
  end

  def product
    @_product ||= content_fee.product
  end

  def calculate_vat
    object.budget.to_f * 20 / 100 if [country_agency, country_advertiser].include?('United Kingdom')
  end

  def country_agency
    agency.country if agency.present?
  end

  def country_advertiser
    advertiser.country if advertiser.present?
  end
end
