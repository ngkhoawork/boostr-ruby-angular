require 'rails_helper'

describe BillingSummary::IosMissingMonthlyActualSerializer do
  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
  end

  it 'has proper serialized data' do
    expect(serializer[:io_id]).to eql io.id
    expect(serializer[:io_number]).to eql io.io_number
    expect(serializer[:io_name]).to eql io.name
    expect(serializer[:line_number]).to eql display_line_item.line_number
    expect(serializer[:advertiser_name]).to eql advertiser.name
    expect(serializer[:currency]).to eql io.curr_cd
    expect(serializer[:billing_contact_name]).to eql contact.name
    expect(serializer[:product_name]).to eql product.name
    expect(serializer[:ad_server]).to eql display_line_item.ad_server
  end

  private

  def serializer
    @_serializer ||= ios_missing_monthly_actual_serializer.serializable_hash
  end

  def ios_missing_monthly_actual_serializer
    described_class.new(display_line_item)
  end

  def display_line_item
    @_display_line_item ||= create :display_line_item, io: io, product: product, line_number: 20
  end

  def company
    @_company ||= create :company
  end

  def io
    @_io ||= create :io, start_date: start_date, end_date: end_date, advertiser: advertiser, deal: deal, company: company
  end

  def advertiser
    @_advertiser ||= create :client, company: company
  end

  def account_manager
    @_account_manager ||= create :user, email: 'test@email.com', user_type: ACCOUNT_MANAGER
  end

  def deal
    @_deal ||= create :deal,
                      creator: account_manager,
                      budget: 20_000,
                      advertiser: advertiser,
                      company: company
  end

  def product
    @_product ||= create :product, company: company, revenue_type: 'Test Fee'
  end

  def contact
    @_contact ||= create :contact,
                         clients: [advertiser],
                         company: company
  end

  def date
    @_date ||= Date.parse('26/03/2017')
  end

  def start_date
    @_start_date ||= date.beginning_of_month
  end

  def end_date
    @_end_date ||= date.end_of_month
  end
end
