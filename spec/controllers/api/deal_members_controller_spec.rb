require 'rails_helper'

RSpec.describe Api::DealMembersController, type: :controller do
  let(:company) { create :company }
  let(:deal) { create :deal, company: company }
  let(:user) { create :user, company: company }
  let(:deal_member_params) { attributes_for :deal_member, user_id: user.id }

  before do
    sign_in user
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

  describe 'POST #create' do
    it 'creates a new deal_member and returns success' do
      expect do
        post :create, deal_id: deal.id, deal_member: deal_member_params, format: :json
        expect(response).to be_success
        response_json = JSON.parse(response.body)
        expect(response_json['user_id']).to eq(user.id)
        expect(response_json['deal_id']).to eq(deal.id)
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
end
