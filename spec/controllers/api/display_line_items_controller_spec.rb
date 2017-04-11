require 'rails_helper'

describe Api::DisplayLineItemsController, type: :controller do
  before { sign_in user }

  describe 'GET #show' do
    before do
      create :io_member, user: user, io: create_io
      create :display_line_item_budget,
             display_line_item: display_line_item,
             budget: 10_000,
             budget_loc: 10_000,
             start_date: '01/11/2016',
             end_date: '30/11/2016'
    end

    it 'return proper data for showing display line item' do
      get :show, id: display_line_item.id, format: :json

      response_json = response_json(response)

      expect(response).to be_success
      expect(response_json.first['month']).to eq 'Oct 2016'
      expect(response_json.last['month']).to eq 'Nov 2016'
      expect(response_json.last['budget'].to_i).to eq 10_000
    end
  end

  describe 'POST #add_budget' do
    before do
      create :io_member, user: user, io: create_io
    end

    it 'create new display line item budget with valid params successfully' do
      expect{
        post :add_budget, id: display_line_item.id, display_line_item_budget: valid_budget_params, format: :json
      }.to change(DisplayLineItemBudget, :count).by(1)

      display_line_item_budget = display_line_item.display_line_item_budgets.last

      expect(display_line_item_budget.start_date).to eq valid_budget_params[:month].to_date.beginning_of_month
      expect(display_line_item_budget.end_date).to eq valid_budget_params[:month].to_date.end_of_month
      expect(display_line_item_budget.budget.to_i).to eq valid_budget_params[:budget]
      expect(display_line_item_budget.budget_loc.to_i).to eq valid_budget_params[:budget]
    end

    it 'failed to create display line item budget with invalid params' do
      expect{
        post :add_budget, id: display_line_item.id, display_line_item_budget: invalid_budget_params, format: :json
      }.to_not change(DisplayLineItemBudget, :count)
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
      budget: 20_000,
      start_date: '01/10/2016',
      end_date: '30/11/2016'
    )
  end

  def valid_budget_params
    { budget: 2_000, month: 'Oct 2016' }
  end

  def invalid_budget_params
    { budget: 40_000, month: 'Oct 2016' }
  end
end
