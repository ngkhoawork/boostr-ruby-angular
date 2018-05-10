require 'rails_helper'

describe Api::DisplayLineItemsController, type: :controller do
  before do
    create_gbp_currency
    sign_in user
  end

  describe 'GET #index' do
    before do
      Timecop.freeze(2016, 8, 1)
      create :io, company: company, display_line_items: [create_item]
      create :io, company: company, display_line_items: [create_item]
      create :io, company: company, display_line_items: [create_item]
    end

    it 'has appropriate count of record in response with risk filter' do
      create :io, company: company, display_line_items: [create_negative_item]

      get :index, filter: 'risk', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
    end

    it 'has appropriate count of record in response with upside filter' do
      get :index, filter: 'upside', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(3)
    end

    it 'has appropriate display line items if filter by io name' do
      create :io, name: 'Io 930',company: company, display_line_items: [create_item]

      get :index, filter: 'upside', name: '930', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['io']['name']).to eq('Io 930')
    end

    it 'has appropriate ios if filter by started date' do
      get :index, end_date: '2016-11-01', start_date: '2016-05-01', filter: 'upside', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(3)
    end

    it 'has display line items with ios related to specific agency' do
      io = create :io, name: 'Io 930',company: company, display_line_items: [create_item]
      agency = io.agency

      get :index, name: agency.name, filter: 'upside', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['io']['agency']['name']).to eq(agency.name)
    end

    it 'has display line items with ios related to specific advertiser' do
      io = create :io, name: 'Io 930',company: company, display_line_items: [create_item]
      advertiser = io.advertiser

      get :index, name: advertiser.name, filter: 'upside', format: :json

      response_json = response_json(response)

      expect(response_json.count).to eq(1)
      expect(response_json.first['io']['advertiser']['name']).to eq(advertiser.name)
    end
  end

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
      expect(response_json.last['budget_loc'].to_i).to eq 10_000
    end
  end

  describe 'POST #add_budget' do
    context 'with usd currency' do
      before { create :io_member, user: user, io: create_io }

      it 'create new display line item budget with valid params successfully' do
        expect{
          post :add_budget, id: display_line_item.id, display_line_item_budget: valid_budget_params, format: :json
        }.to change(DisplayLineItemBudget, :count).by(1)

        display_line_item_budget = display_line_item.reload.display_line_item_budgets.last

        expect(display_line_item_budget.start_date).to eq valid_budget_params[:month].to_date.beginning_of_month
        expect(display_line_item_budget.end_date).to eq valid_budget_params[:month].to_date.end_of_month
        expect(display_line_item_budget.budget.to_i).to eq valid_budget_params[:budget_loc]
        expect(display_line_item_budget.budget_loc.to_i).to eq valid_budget_params[:budget_loc]
      end
    end

    context 'with gbp currency' do
      before { create :io_member, user: user, io: create_io_with_gbp_currency }

      it 'create new display line item budget with valid params successfully' do
        expect{
          post :add_budget, id: display_line_item.id, display_line_item_budget: valid_budget_params, format: :json
        }.to change(DisplayLineItemBudget, :count).by(1)

        display_line_item_budget = display_line_item.reload.display_line_item_budgets.last

        expect(display_line_item_budget.start_date).to eq valid_budget_params[:month].to_date.beginning_of_month
        expect(display_line_item_budget.end_date).to eq valid_budget_params[:month].to_date.end_of_month
        expect(display_line_item_budget.budget.to_i).to eq 1_666
        expect(display_line_item_budget.budget_loc.to_i).to eq 2_000
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
      budget_loc: 20_000,
      start_date: '01/10/2016',
      end_date: '30/11/2016'
    )
  end

  def valid_budget_params
    { budget_loc: 2_000, month: 'Oct 2016' }
  end

  def create_gbp_currency
    @_gbp_currency ||=
      (
        Currency.find_by(curr_cd: 'GBP', curr_symbol: '£', name: 'Great Britain Pound') ||
        create(:currency, curr_cd: 'GBP', curr_symbol: '£', name: 'Great Britain Pound')
      ).tap do |c|
        c.exchange_rates << exchange_rate unless c.exchange_rates.include?(exchange_rate)
      end
  end

  def exchange_rate
    @_exchange_rate ||= create(:exchange_rate, company: company, rate: 1.2, currency: currency)
  end

  def currency
    @_currency ||= Currency.first || create(:currency)
  end

  def create_item
    create :display_line_item,
           balance: 5_000,
           budget: 40_000,
           budget_remaining: 5_000.0,
           start_date: '20/07/2016',
           end_date: '01/10/2016'
  end

  def create_negative_item
    create :display_line_item,
           balance: 5_000,
           budget: 10_000,
           budget_remaining: 20_000.0,
           start_date: '01/06/2016',
           end_date: '01/10/2016'
  end
end
