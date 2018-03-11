require 'rails_helper'

describe BillingSummary::IosForApprovalSerializer do
  before do
    create :billing_address_validation, company: company
    create :billing_deal_contact, deal: deal, contact: contact
    content_fee = create :content_fee, product: content_fee_product, budget: 50_000, io: io
    io.content_fees << content_fee

    create_io_members
    display_line_item_budget
  end

  it 'has proper serialized data' do
    expect(display_line_item_serializer_budget[:io_number]).to eql io.io_number
    expect(display_line_item_serializer_budget[:io_name]).to eql io.name
    expect(display_line_item_serializer_budget[:advertiser_name]).to eql advertiser.name
    expect(display_line_item_serializer_budget[:currency]).to eql io.curr_cd
    expect(display_line_item_serializer_budget[:currency_symbol]).to eql io.currency.curr_symbol
    expect(display_line_item_serializer_budget[:billing_contact_name]).to eql contact.name
    expect(display_line_item_serializer_budget[:product_name]).to eql display_line_item_product.name
    expect(display_line_item_serializer_budget[:revenue_type]).to eql display_line_item_product.revenue_type
    expect(display_line_item_serializer_budget[:vat]).to eq calculate_line_item_vat
    expect(display_line_item_serializer_budget[:line]).to eql display_line_item.line_number
    expect(display_line_item_serializer_budget[:ad_server]).to eql display_line_item.ad_server
    expect(display_line_item_serializer_budget[:budget_loc]).to eql display_line_item_budget.budget_loc.to_f
    expect(display_line_item_serializer_budget[:billing_status]).to eql 'Pending'

    expect(content_fee_product_budget_serializer[:io_number]).to eql io.io_number
    expect(content_fee_product_budget_serializer[:io_name]).to eql io.name
    expect(content_fee_product_budget_serializer[:advertiser_name]).to eql advertiser.name
    expect(content_fee_product_budget_serializer[:currency]).to eql io.curr_cd
    expect(content_fee_product_budget_serializer[:currency_symbol]).to eql io.currency.curr_symbol
    expect(content_fee_product_budget_serializer[:billing_contact_name]).to eql contact.name
    expect(content_fee_product_budget_serializer[:product_name]).to eql content_fee_product.name
    expect(content_fee_product_budget_serializer[:revenue_type]).to eql content_fee_product.revenue_type
    expect(content_fee_product_budget_serializer[:line]).to eql content_fee.id
    expect(content_fee_product_budget_serializer[:amount]).to eql content_fee_product_budget.budget_loc.to_f
    expect(content_fee_product_budget_serializer[:billing_status]).to eql 'Pending'
    expect(content_fee_product_budget_serializer[:seller_name]).to eql user_seller.name
  end

  private

  def display_line_item_serializer_budget
    @_display_line_item_serializer_budget ||= serializer[:display_line_item_budgets].first
  end

  def content_fee_product_budget_serializer
    @_content_fee_product_budget_serializer ||= serializer[:content_fee_product_budgets].first
  end

  def serializer
    ios_for_approval.serializable_hash
  end

  def ios_for_approval
    described_class.new(io, start_date: start_date, end_date: end_date)
  end

  def content_fee
    @_content_fee ||= io.content_fees.first
  end

  def content_fee_product_budget
   @_content_fee_product_budget ||= content_fee.content_fee_product_budgets.first
  end

  def create_io_members
    create :io_member, user_id: user_seller.id, io_id: io.id, share: 100
    create :io_member, user_id: user.id, io_id: io.id, share: 85
  end

  def user
    @_user ||= create :user
  end

  def io
    @_io ||= create(
      :io,
      start_date: start_date,
      end_date: end_date,
      advertiser: advertiser,
      deal: deal,
      display_line_items: [display_line_item],
      company: company
    )
  end

  def display_line_item
    @_display_line_item ||= create(
      :display_line_item,
      start_date: start_date,
      end_date: end_date,
      product: display_line_item_product,
      line_number: 20,
      budget: 30_000,
      budget_loc: 30_000
    )
  end

  def display_line_item_budget
    @_display_line_item_budget ||= create(
      :display_line_item_budget,
      start_date: start_date,
      end_date: end_date,
      budget: 20_000,
      budget_loc: 20_000,
      display_line_item: display_line_item
    )
  end

  def display_line_item_product
    @_display_line_item_product ||= create :product, company: company, revenue_type: 'Test Line'
  end

  def content_fee_product
    @_content_fee_product ||= create :product, company: company, revenue_type: 'Test Fee'
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

  def advertiser
    @_advertiser ||= create :client, company: company, address: address
  end

  def deal
    @_deal ||= create :deal,
                      creator: account_manager,
                      budget: 20_000,
                      advertiser: advertiser,
                      company: company
  end

  def company
    @_company ||= create :company
  end

  def account_manager
    @_account_manager ||= create :user, email: 'test@email.com', user_type: ACCOUNT_MANAGER
  end

  def user_seller
    @_seller ||= create :user, user_type: SELLER, first_name: 'John', last_name: 'Test'
  end

  def contact
    @_contact ||= create :contact,
                         clients: [advertiser],
                         company: company,
                         address: address
  end

  def address
    create :address, country: 'United Kingdom'
  end

  def calculate_line_item_vat
    display_line_item_budget.budget * 20 / 100
  end
end
