require 'rails_helper'

describe Api::DisplayLineItemBudgetsController, type: :controller do
  before { sign_in user }

  describe 'PUT #update' do
    before { create :io_member, user: user, io: create_io }

    it 'update display line item budget with valid params successfully' do
      expect(display_line_item_budget.budget.to_i).to eq 10_000

      put :update, id: display_line_item_budget.id, display_line_item_budget: valid_budget_params, format: :json

      display_line_item_budget.reload

      expect(display_line_item_budget.budget.to_i).to eq 5_000
    end

    it 'failed to update display line item budget with invalid params' do
      expect(display_line_item_budget.budget.to_i).to eq 10_000

      put :update, id: display_line_item_budget.id, display_line_item_budget: invalid_budget_params, format: :json

      display_line_item_budget.reload

      expect(display_line_item_budget.budget.to_i).to eq 10_000
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
        price: 10,
        budget: 20_000
    )
  end

  def display_line_item_budget
    @_display_line_item_budget ||= create :display_line_item_budget,
                                          display_line_item: display_line_item,
                                          budget: 10_000,
                                          budget_loc: 10_000
  end

  def valid_budget_params
    { budget: 5_000 }
  end

  def invalid_budget_params
    { budget: 40_000 }
  end
end
