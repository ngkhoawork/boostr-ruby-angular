require 'rails_helper'

describe Operative::Deals::Single do
  before { create :billing_deal_contact, contact: create(:contact, clients: [deal.advertiser]), deal: deal }

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
    @_deal ||= create :deal, creator: account_manager, budget: 20_000, deal_members: [deal_member]
  end

  def deal_mapper
    @_deal_mapper ||= described_class.new(deal).to_xml(create: true, advertiser: true, agency: true)
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

  def contact
    @_contact ||= deal.contacts.first
  end

  def deal_start_date
    deal.start_date.strftime('%A, %d %b %Y')
  end

  def deal_end_date
    deal.end_date.strftime('%A, %d %b %Y')
  end

  def deal_member
    create(:deal_member, user: seller)
  end

  def deal_stage
    '<v2:name>10% - Sales lead</v2:name>'
  end

  def deal_alternate_id
    "boostr_#{deal.id}_#{deal.company.name}_order"
  end

  def deal_sales_order_type
    '<name>Agency Buy</name>'
  end

  def primary_sales_person
    "<primarySalesperson>#{seller.email}</primarySalesperson>"
  end

  def owner
    "<owner>#{account_manager.email}</owner>"
  end

  def agency
    @_agency ||= deal.agency
  end

  def advertiser
    @_advertiser ||= deal.advertiser
  end
end
