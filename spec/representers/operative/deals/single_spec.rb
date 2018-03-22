require 'rails_helper'

describe Operative::Deals::Single, operative: true do
  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
  end

  it 'has proper mapped value' do
    expect(deal_mapper).to include deal_name
    expect(deal_mapper).to include deal_alternate_id
    expect(deal_mapper).to include deal.next_steps
    expect(deal_mapper).to include deal_description
    expect(deal_mapper).to include deal_sales_order_type
    expect(deal_mapper).to include deal_stage
    expect(deal_mapper).to include deal_agency_external_id
    expect(deal_mapper).to include deal_agency_name
    expect(deal_mapper).to include deal_advertiser_external_id
    expect(deal_mapper).to include deal_advertiser_name
    expect(deal_mapper).to include primary_sales_person
    expect(deal_mapper).to include owner
    expect(deal_mapper).to include deal_contact_external_id
  end

  private


  def deal
    @_deal ||= create :deal,
                      creator: account_manager,
                      budget: 20_000,
                      advertiser: advertiser,
                      agency: agency,
                      company: company
  end

  def advertiser
    @_advertiser ||= create :client, company: company
  end

  def agency
    @_agency ||= create :client, company: company
  end

  def deal_mapper
    @_deal_mapper ||= described_class.new(deal).to_xml(
      create: true,
      advertiser: true,
      agency: true,
      contact: true,
      enable_operative_extra_fields: false,
      buzzfeed: false
    )
  end

  def deal_name
    "#{deal.name}_#{deal.id}"
  end

  def account_manager
    @_account_manager ||= create :user, email: 'test@email.com', user_type: ACCOUNT_MANAGER
  end

  def seller
    @_seller ||= create :user, email: 'second_test@email.com', user_type: SELLER
  end

  def deal_description
    "Budget: $20,000.00, start date: #{deal_start_date}, end_date: #{deal_end_date}"
  end

  def deal_agency_external_id
    "<externalId>boostr_#{agency.id}_#{agency.company.name}_account</externalId>"
  end

  def deal_agency_name
    "<name>#{agency.name}</name>"
  end

  def deal_advertiser_external_id
    "<externalId>boostr_#{advertiser.id}_#{advertiser.company.name}_account</externalId>"
  end

  def deal_advertiser_name
    "<name>#{advertiser.name}</name>"
  end

  def deal_contact_external_id
    "boostr_#{contact.id}_#{contact.company.name}_contact"
  end

  def deal_start_date
    deal.start_date.strftime('%A, %d %b %Y')
  end

  def deal_end_date
    deal.end_date.strftime('%A, %d %b %Y')
  end

  def deal_stage
    "<v2:name>#{deal.stage.name}</v2:name>"
  end

  def deal_alternate_id
    "boostr_#{deal.id}_#{deal.company.name}_order"
  end

  def deal_sales_order_type
    '<name>Agency Buy</name>'
  end

  def primary_sales_person
    "<primarySalesperson>#{account_manager.email}</primarySalesperson>"
  end

  def owner
    "<owner>#{account_manager.email}</owner>"
  end

  def company
    @_company ||= create :company
  end

  def contact
    @_contact ||= create :contact,
                         clients: [advertiser],
                         company: company
  end
end
