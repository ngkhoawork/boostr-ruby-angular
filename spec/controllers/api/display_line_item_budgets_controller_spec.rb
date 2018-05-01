require 'rails_helper'

describe Api::DisplayLineItemBudgetsController, type: :controller do
  before do
    create_gbp_currency
    sign_in user
  end

  describe 'PUT #update' do
    context 'with usd currency' do
      before { create :io_member, user: user, io: create_io }

      it 'update display line item budget with valid params successfully' do
        expect(display_line_item_budget.budget.to_i).to eq 10_000
        expect(display_line_item_budget.budget_loc.to_i).to eq 10_000

        put :update, id: display_line_item_budget.id, display_line_item_budget: valid_budget_params, format: :json

        display_line_item_budget.reload

        expect(display_line_item_budget.budget.to_i).to eq 5_000
        expect(display_line_item_budget.budget_loc.to_i).to eq 5_000
      end
    end

    context 'with gbp currency' do
      before { create :io_member, user: user, io: create_io_with_gbp_currency }

      it 'update display line item budget with valid params successfully' do
        expect(display_line_item_budget.budget.to_i).to eq 10_000
        expect(display_line_item_budget.budget_loc.to_i).to eq 10_000

        put :update, id: display_line_item_budget.id, display_line_item_budget: valid_budget_params, format: :json

        display_line_item_budget.reload

        expect(display_line_item_budget.budget.to_i).to eq 4_166
        expect(display_line_item_budget.budget_loc.to_i).to eq 5_000
      end
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
                      budget_loc: 20_000,
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
    @_display_line_item_budget ||= create :display_line_item_budget,
                                          display_line_item: display_line_item,
                                          budget: 10_000,
                                          budget_loc: 10_000
  end

  def valid_budget_params
    { budget_loc: 5_000 }
  end

  def create_gbp_currency
    @_gbp_currency ||=
      Currency.find_or_create_by(
        curr_cd: 'GBP',
        curr_symbol: '£',
        name: 'Great Britain Pound'
      ).tap do |currency|
        currency.exchange_rates << build(:exchange_rate, company: company, rate: 1.2, currency: currency)
      end
  end
end
