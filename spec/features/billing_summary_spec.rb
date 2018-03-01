require 'rails_helper'

feature 'BillingSummary' do
  before do
    create_io
    create_io_with_missing_display_line_items
    create_io_with_missing_monthly_actual

    create :billing_deal_contact, deal: deal, contact: contact
    create :billing_deal_contact, deal: deal_with_missing_display_line_items, contact: contact
    create :billing_deal_contact, deal: deal_with_missing_monthly_actual, contact: contact

    display_line_item_budget

    login_as user, scope: :user

    visit '/finance/billing'

    select_year_and_month
  end

  it 'has all data in page', js: true do
    expect(ios_for_approval_table).to include io.io_number.to_s
    expect(ios_for_approval_table).to include io.name
    expect(ios_for_approval_table).to include display_line_item.line_number.to_s
    expect(ios_for_approval_table).to include advertiser.name
    expect(ios_for_approval_table).to include contact.name
    expect(ios_for_approval_table).to include display_line_item_product.name
    expect(ios_for_approval_table).to include display_line_item.ad_server
    expect(ios_for_approval_table).to include io.curr_cd

    expect(ios_missing_display_line_items_table).to include io_with_missing_display_line_items.io_number.to_s
    expect(ios_missing_display_line_items_table).to include io_with_missing_display_line_items.name
    expect(ios_missing_display_line_items_table).to include advertiser.name
    expect(ios_missing_display_line_items_table).to include io_with_missing_display_line_items.curr_cd
    expect(ios_missing_display_line_items_table).to include contact.name

    expect(io_with_with_missing_monthly_actual_table).to include io_with_with_missing_monthly_actual.io_number.to_s
    expect(io_with_with_missing_monthly_actual_table).to include io_with_with_missing_monthly_actual.name
    expect(io_with_with_missing_monthly_actual_table).to include display_line_item_with_missing_monthly_actual.line_number.to_s
    expect(io_with_with_missing_monthly_actual_table).to include advertiser.name
    expect(io_with_with_missing_monthly_actual_table).to include io_with_with_missing_monthly_actual.curr_cd
    expect(io_with_with_missing_monthly_actual_table).to include contact.name
    expect(io_with_with_missing_monthly_actual_table).to include display_line_item_product.name
    expect(io_with_with_missing_monthly_actual_table).to include display_line_item_with_missing_monthly_actual.ad_server
  end

  xit 'update content fee product budget successfully', js: true do
    expect(find('.display-line-budget').text).to eq('$20,000.00')

    find('.display-line-quantity').trigger('click')
    find('form.editable-number .editable-input').set(100_000)
    find('.ios-for-approval').click

    wait_for_ajax 1

    expect(find('.display-line-budget').text).to eq('$1,000.00')
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def create_io
    @_io ||= create(
      :io,
      company: company,
      start_date: start_date - 1.month,
      end_date: end_date + 1.month,
      advertiser: advertiser,
      deal: deal,
      display_line_items: [display_line_item]
    )
  end

  def create_io_with_missing_display_line_items
    @_io_with_missing_display_line_items ||= create(
      :io,
      company: company,
      start_date: start_date - 1.month,
      end_date: end_date + 1.month,
      advertiser: advertiser,
      deal: deal_with_missing_display_line_items
    )
  end

  def create_io_with_missing_monthly_actual
    @_io_with_missing_monthly_actual ||= create(
      :io,
      company: company,
      start_date: start_date - 1.month,
      end_date: end_date + 1.month,
      advertiser: advertiser,
      deal: deal_with_missing_monthly_actual,
      display_line_items: [display_line_item_with_missing_monthly_actual]
    )
  end

  def io
    create_io
  end

  def io_with_missing_display_line_items
    @_io_with_missing_display_line_items ||= deal_with_missing_display_line_items.io
  end

  def io_with_with_missing_monthly_actual
    @_io_with_with_missing_monthly_actual ||= create_io_with_missing_monthly_actual
  end

  def date
    @_date ||= Date.parse('26/02/2017')
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

  def address
    create :address, country: 'United Kingdom'
  end

  def deal
    @_deal ||= create :deal,
                      creator: user,
                      budget: 20_000,
                      advertiser: advertiser,
                      company: company
  end

  def deal_with_missing_display_line_items
    @_deal_with_missing_display_line_items ||= create :deal,
                                               creator: user,
                                               budget: 20_000,
                                               advertiser: advertiser,
                                               company: company,
                                               stage: create(:stage, probability: 100),
                                               products: [product_with_missing_display_line_items]
  end

  def deal_with_missing_monthly_actual
    @_deal_with_missing_monthly_actual ||= create :deal,
                                                  creator: user,
                                                  budget: 20_000,
                                                  advertiser: advertiser,
                                                  company: company
  end

  def display_line_item
    @_display_line_item ||= create(
      :display_line_item,
      start_date: start_date,
      end_date: end_date,
      product: display_line_item_product,
      line_number: 20,
      price: 10,
      budget: 30_000,
      budget_loc: 30_000
    )
  end

  def display_line_item_with_missing_monthly_actual
    @_display_line_item_with_missing_monthly_actual ||= create(
      :display_line_item,
      start_date: start_date,
      end_date: end_date,
      product: display_line_item_product,
      line_number: 30
    )
  end

  def display_line_item_product
    @_display_line_item_product ||= create :product, company: company, revenue_type: 'Test Line'
  end

  def product_with_missing_display_line_items
    @_product_with_missing_display_line_items ||= create :product, company: company, revenue_type: 'Display'
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

  def contact
    @_contact ||= create :contact,
                         clients: [advertiser],
                         company: company
  end

  def ios_for_approval_table
    @_ios_for_approval_table ||= find('.ios-for-approval tbody tr').text
  end

  def ios_missing_display_line_items_table
    @_ios_missing_display_line_items_table ||= find('.ios-missing-display-line-items tbody tr').text
  end

  def io_with_with_missing_monthly_actual_table
    @_io_with_with_missing_monthly_actual_table ||= find('.ios-missing-monthly-actual tbody tr').text
  end

  def select_year_and_month
    find('.year-toggle').click
    find('.year-dropdown li', text: '2017').click

    find('.month-toggle').click
    find('.month-dropdown li', text: 'February').click
  end
end
