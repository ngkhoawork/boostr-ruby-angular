require 'rails_helper'

RSpec.describe Api::DealMembersController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:stage) { create :stage, company: company, position: 1 }
  let(:client) { create :client }
  let!(:deal) { create :deal, stage: stage, company: company, creator: user, end_date: Date.new(2016, 6, 29), advertiser: client }
  let(:deal_member_params) { attributes_for :deal_member, user_id: user.id }

  before do
    sign_in user
  end

  describe 'POST #create' do
    render_views

    it 'creates a new deal_member and returns success' do
      expect do
        post :create, deal_id: deal.id, deal_member: deal_member_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['members'].length).to eq(1)
        expect(response_json['members'][0]['user_id']).to eq(user.id)
        expect(response_json['id']).to eq(deal.id)
      end.to change(DealMember, :count).by(1)
    end

    it 'returns errors if the deal_member is invalid' do
      expect do
        post :create, deal_id: deal.id, deal_member: { bad: 'param' }, format: :json
        expect(response.status).to eq(422)
        response_json = JSON.parse(response.body)
        expect(response_json['errors']['share']).to eq(["can't be blank"])
      end.to_not change(DealMember, :count)
    end
  end

  describe 'GET #index' do
    let!(:deal_member) { create :deal_member, deal_id: deal.id, user_id: user.id }
    it 'returns a list of deal_members' do
      get :index, deal_id: deal.id, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
    end
  end

  describe 'PUT #update' do
    render_views

    let!(:deal_member) { create :deal_member, deal_id: deal.id, user_id: user.id }
    it 'updates the deal member' do
      put :update, id: deal_member.id, deal_id: deal.id, deal_member: { share: '62' }, format: :json
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json['members'][0]['share']).to eq(62)
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal_member) { create :deal_member, deal_id: deal.id, user_id: user.id }
    it 'delete the deal member' do
      delete :destroy, id: deal_member.id, deal_id: deal.id, format: :json
      expect(response).to be_success
    end
  end
end
