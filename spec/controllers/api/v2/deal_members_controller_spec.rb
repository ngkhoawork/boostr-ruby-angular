require 'rails_helper'

RSpec.describe Api::V2::DealMembersController, type: :controller do
  let!(:deal) do
    create(
      :deal,
      stage: stage,
      company: company,
      creator: user,
      end_date: Date.new(2016, 6, 29),
      advertiser: client
    )
    end

  before do
    valid_token_auth user
  end

  describe 'POST #create' do
    render_views

    it 'creates a new deal_member and returns success' do
      expect do
        post :create, deal_id: deal.id, deal_member: deal_member_params, format: :json
        response_json = JSON.parse(response.body)

        expect(response).to be_success
        expect(response_json['members'].length).to eq(2)
        expect(response_json['members'][0]['user_id']).to eq(user.id)
        expect(response_json['id']).to eq(deal.id)
      end.to change(DealMember, :count).by(1)
    end

    it 'returns errors if the deal_member is invalid' do
      expect do
        post :create, deal_id: deal.id, deal_member: { bad: 'param' }, format: :json
        response_json = JSON.parse(response.body)

        expect(response.status).to eq(422)
        expect(response_json['errors']['share']).to eq(["can't be blank"])
      end.to_not change(DealMember, :count)
    end
  end

  describe 'GET #index' do
    it 'returns a list of deal_members' do
      get :index, deal_id: deal.id, format: :json
      response_json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response_json.length).to eq(1)
    end
  end

  describe 'PUT #update' do
    render_views

    it 'updates the deal member' do
      put :update, id: deal_member.id, deal_id: deal.id, deal_member: { share: '62' }, format: :json
      response_json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response_json['members'][1]['share']).to eq(62)
    end
  end

  describe 'DELETE #destroy' do
    before { deal_member }

    it 'deletes the deal member' do
      expect do
        delete :destroy, id: deal_member.id, deal_id: deal.id, format: :json

        expect(response).to be_success
      end.to change(DealMember, :count).by(-1)
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def stage
    @_stage ||= create :stage, company: company, position: 1
  end

  def client
    @_client ||= create :client
  end

  def deal_member_params
    @_deal_member_params ||= attributes_for :deal_member, user_id: user.id
  end

  def deal_member
    @_deal_member ||= create :deal_member, deal_id: deal.id, user_id: user.id
  end
end
