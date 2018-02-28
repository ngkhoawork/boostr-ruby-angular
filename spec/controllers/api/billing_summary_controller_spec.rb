require 'rails_helper'

describe Api::BillingSummaryController do
  before do
    create_gbp_currency
    sign_in user
  end

  describe 'PUT #update_quantity' do
    it 'update quantity with usd currency successfully' do
      create_io

      put :update_quantity,
          id: display_line_item_budget,
          display_line_item_budget: { quantity: 200_000 },
          format: :json

      display_line_item_budget.reload

      expect(display_line_item_budget.quantity).to eql 200_000
      expect(display_line_item_budget.budget.to_i).to eql 2_000
      expect(display_line_item_budget.budget_loc.to_i).to eql 2_000
      expect(display_line_item_budget.manual_override).to eql true
    end

    it 'update quantity with gbp currency successfully' do
      create_io_with_gbp_currency

      put :update_quantity,
          id: display_line_item_budget,
          display_line_item_budget: { quantity: 200_000 },
          format: :json

      display_line_item_budget.reload

      expect(display_line_item_budget.quantity).to eql 200_000
      expect(display_line_item_budget.budget.to_i).to eql 1_666
      expect(display_line_item_budget.budget_loc.to_i).to eql 2_000
      expect(display_line_item_budget.manual_override).to eql true
    end
  end

  describe 'PUT #update_display_line_item_budget_billing_status' do
    it 'update billing status successfully' do
      put :update_display_line_item_budget_billing_status,
          id: display_line_item_budget,
          display_line_item_budget: { billing_status: 'Approved' },
          format: :json

      display_line_item_budget.reload

      expect(display_line_item_budget.billing_status).to eql 'Approved'
    end
  end

  describe 'PUT #update_content_fee_product_budget' do
    it 'update billing status successfully' do
      create_content_fee

      put :update_content_fee_product_budget,
          id: content_fee_product_budget,
          content_fee_product_budget: { billing_status: 'Approved' },
          format: :json

      content_fee_product_budget.reload

      expect(content_fee_product_budget.billing_status).to eql 'Approved'
    end

    it 'update budget with usd successfully' do
      create_content_fee

      put :update_content_fee_product_budget,
          id: content_fee_product_budget,
          content_fee_product_budget: { budget_loc: 20_000 },
          format: :json

      content_fee_product_budget.reload

      expect(content_fee_product_budget.budget.to_i).to eql 20_000
      expect(content_fee_product_budget.budget_loc.to_i).to eql 20_000
      expect(content_fee_product_budget.content_fee.budget.to_i).to eql 20_000
      expect(content_fee_product_budget.content_fee.budget_loc.to_i).to eql 20_000
      expect(content_fee_product_budget.content_fee.io.budget.to_i).to eql 20_000
      expect(content_fee_product_budget.content_fee.io.budget_loc.to_i).to eql 20_000
      expect(content_fee_product_budget.manual_override).to eql true
    end

    it 'update budget with gbp successfully' do
      create_content_fee_with_gbp_currency

      put :update_content_fee_product_budget,
          id: content_fee_product_budget,
          content_fee_product_budget: { budget_loc: 20_000 },
          format: :json

      content_fee_product_budget.reload

      expect(content_fee_product_budget.budget.to_i).to eql 16_666
      expect(content_fee_product_budget.budget_loc.to_i).to eql 20_000
      expect(content_fee_product_budget.content_fee.budget.to_i).to eql 16_666
      expect(content_fee_product_budget.content_fee.budget_loc.to_i).to eql 20_000
      expect(content_fee_product_budget.content_fee.io.budget.to_i).to eql 16_666
      expect(content_fee_product_budget.content_fee.io.budget_loc.to_i).to eql 20_000
      expect(content_fee_product_budget.manual_override).to eql true
    end
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
      advertiser: advertiser,
      deal: deal,
      display_line_items: [display_line_item]
    )
  end

  def create_io_with_gbp_currency
    @_io_with_gbp ||= create(
        :io,
        curr_cd: 'GBP',
        company: company,
        advertiser: advertiser,
        deal: deal,
        display_line_items: [display_line_item]
    )
  end


  def advertiser
    @_advertiser ||= create :client, company: company
  end

  def deal
    @_deal ||= create :deal,
                      creator: user,
                      budget: 20_000,
                      advertiser: advertiser,
                      company: company
  end

  def display_line_item
    @_display_line_item ||= create(
      :display_line_item,
      price: 10,
      budget: 20_000,
      budget_loc: 20_000
    )
  end

  def display_line_item_budget
    @_display_line_item_budget ||= create :display_line_item_budget, display_line_item: display_line_item
  end

  def create_content_fee
    @_content_fee ||= create :content_fee, content_fee_product_budgets: [content_fee_product_budget], io: create_io
  end

  def create_content_fee_with_gbp_currency
    @_content_fee ||= create :content_fee,
                             content_fee_product_budgets: [content_fee_product_budget],
                             io: create_io_with_gbp_currency
  end

  def content_fee_product_budget
    @_content_fee_product_budget ||= create :content_fee_product_budget
  end

  def create_gbp_currency
    @_gbp_currency ||=
      Currency.find_or_create_by(curr_cd: 'GBP', curr_symbol: '£', name: 'Great Britain Pound').tap do |currency|
        currency.exchange_rates << build(:exchange_rate, company: company, rate: 1.2, currency: currency)
      end
  end
end
