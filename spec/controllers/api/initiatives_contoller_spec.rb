require 'rails_helper'

describe Api::InitiativesController do
  before { sign_in user }

  describe 'GET #index' do
    before do
      2.times { create :initiative, company: company }
      create :initiative, company: create(:company)
    end

    it 'return all initiatives related to specific company' do
      get :index, format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq(2)
    end
  end

  describe 'POST #create' do
    it 'creates new initiative with valid params successfully' do
      expect{
        post :create, initiative: valid_initiative_params, format: :json
      }.to change(Initiative, :count).by(1)
    end

    it 'failed when params are invalid' do
      expect{
        post :create, initiative: invalid_initiative_params, format: :json
      }.to_not change(Initiative, :count)
    end
  end

  describe 'PUT #update' do
    it 'update with initiative with valid params successfully' do
      put :update, id: initiative.id, initiative: valid_initiative_params, format: :json

      initiative.reload

      expect(initiative.name).to eq valid_initiative_params[:name]
      expect(initiative.goal).to eq valid_initiative_params[:goal]
    end

    it 'failed when params are invalid' do
      put :update, id: initiative.id, initiative: invalid_initiative_params, format: :json

      initiative.reload

      expect(initiative.name).to_not eq valid_initiative_params[:name]
      expect(initiative.goal).to_not eq valid_initiative_params[:goal]
    end
  end

  describe 'DELETE #destroy' do
    it 'delete initiative successfully' do
      initiative = create :initiative, company: company

      expect{
        delete :destroy, id: initiative.id, format: :json
      }.to change(Initiative, :count).by(-1)
    end
  end

  describe 'GET #smart_report' do
    before do
      2.times { create :initiative, company: company }
      create :initiative, company: create(:company)
    end

    it 'has proper count of initiatives report' do
      get :smart_report, format: :json

      expect(response).to be_success
      expect(response_json(response).length).to eq(2)
    end
  end

  describe 'GET #smart_report_deals' do
    it 'has proper count of deals for initiative' do
      get :smart_report_deals, id: initiative.id, format: :json

      expect(response).to be_success
      expect(response_json(response)['won_deals'].first['name']).to eq won_deal.name
      expect(response_json(response)['lost_deals'].first['name']).to eq lost_deal.name
      expect(response_json(response)['open_deals'].first['name']).to eq open_deal.name
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company, user_type: ADMIN
  end

  def response_json(response)
    @_response_json ||= JSON.parse(response.body)
  end

  def initiative
    @_initiative ||= create :initiative, company: company, deals: [won_deal, lost_deal, open_deal]
  end

  def valid_initiative_params
    {
      goal: 200_000,
      status: 'Open',
      name: 'Test initiative'
    }
  end

  def invalid_initiative_params
    {
      goal: 20_000,
      status: 'close',
      name: ''
    }
  end

  def won_deal
    @_won_deal ||= create :deal, company: company, name: 'Won Deal', stage: create(:stage, probability: 100, open: false)
  end

  def lost_deal
    @_lost_deal ||= create :deal, company: company, name: 'Lost Deal', stage: create(:stage, probability: 0, open: false)
  end

  def open_deal
    @_open_deal ||= create :deal, company: company, name: 'Open Deal'
  end
end
