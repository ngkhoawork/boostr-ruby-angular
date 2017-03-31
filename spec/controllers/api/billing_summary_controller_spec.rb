require 'rails_helper'

describe Api::BillingSummaryController do
  before { sign_in user }

  describe 'PUT #update_quantity' do
    before { create_io }

    it 'update quantity successfully' do
      put :update_quantity,
          id: display_line_item_budget,
          display_line_item_budget: { quantity: 20_000 },
          format: :json

      display_line_item_budget.reload

      expect(display_line_item_budget.quantity).to eql 20_000
      expect(display_line_item_budget.budget.to_i).to eql 400
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
      put :update_content_fee_product_budget,
          id: content_fee_product_budget,
          content_fee_product_budget: { billing_status: 'Approved' },
          format: :json

      content_fee_product_budget.reload

      expect(content_fee_product_budget.billing_status).to eql 'Approved'
    end

    it 'update budget successfully' do
      put :update_content_fee_product_budget,
          id: content_fee_product_budget,
          content_fee_product_budget: { budget: 20_000 },
          format: :json

      content_fee_product_budget.reload

      expect(content_fee_product_budget.budget).to eql 20_000
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
      price: 20
    )
  end

  def display_line_item_budget
    @_display_line_item_budget ||= create :display_line_item_budget, display_line_item: display_line_item
  end

  def content_fee
    @_content_fee ||= create :content_fee, content_fee_product_budgets: [content_fee_product_budget], io: create_io
  end

  def content_fee_product_budget
    @_content_fee_product_budget ||= create :content_fee_product_budget
  end
end
