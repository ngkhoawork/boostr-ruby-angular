require 'rails_helper'

RSpec.describe Api::DealsController, type: :controller do
  let(:company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, company: company, team: team }
  let(:advertiser) { create :client, company: company }
  let(:deal_params) { attributes_for(:deal, advertiser_id: advertiser.id, budget: '31000') }
  let(:deal) { create :deal, company: company }

  before do
    sign_in user
  end

  describe 'GET #index' do
    let!(:leader_deal) { create :deal, company: company, advertiser: advertiser }

    let(:user_deal) { create :deal, company: company, advertiser: advertiser }
    let!(:deal_member) { create :deal_member, deal: user_deal, user: user  }

    let(:team_deal) { create :deal, company: company, advertiser: advertiser }
    let(:another_user) { create :user, company: company, team: team }
    let!(:another_deal_member) { create :deal_member, deal: team_deal, user: another_user  }

    it 'returns a list of deals for the current_user' do
      get :index, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
      expect(response_json[0]['id']).to eq(user_deal.id)
    end

    it 'returns a list of the deals for the current_user team' do
      get :index, filter: 'team', format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(2)
    end

    it 'returns a list of deals for the current_user company if they are a leader' do
      team.update_attributes(leader: user)

      get :index, filter: 'company', format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(3)
    end
  end

  describe 'POST #create' do
    it 'creates a new deal and returns success' do
      expect do
        post :create, deal: deal_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['created_by']).to eq(user.id)
        expect(response_json['budget']).to eq(3_100_000)
        expect(response_json['advertiser_id']).to eq(advertiser.id)
        expect(response_json['next_steps']).to eq(deal_params[:next_steps])
      end.to change(Deal, :count).by(1)
    end

    it 'returns errors if the deal is invalid' do
      expect do
        post :create, deal: attributes_for(:deal), format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['advertiser_id']).to eq(["can't be blank"])
      end.to_not change(Deal, :count)
    end
  end

  describe 'GET #show' do
    it 'returns json for a deal, products and deal_products' do
      get :show, id: deal.id, format: :json
      expect(response).to be_success
    end
  end

  describe 'PUT #update' do
    it 'updates the deal and returns success' do
      put :update, id: deal.id, deal: { start_date: Date.new(2015, 8, 1) }, format: :json
      expect(response).to be_success
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal) { create :deal, company: company, advertiser: advertiser }

    it 'marks the deal as deleted' do
      delete :destroy, id: deal.id, format: :json
      expect(response).to be_success
      expect(deal.reload.deleted_at).to_not be_nil
    end
  end
end
