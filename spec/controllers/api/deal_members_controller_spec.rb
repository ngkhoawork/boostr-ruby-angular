require 'rails_helper'

describe Api::DealMembersController, type: :controller do
  before do
    sign_in user
    User.current = user
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
      end.to change(DealMember, :count).by(2)
    end

    it 'returns errors if the deal_member is invalid' do
      post :create, deal_id: deal.id, deal_member: { bad: 'param' }, format: :json
      response_json = JSON.parse(response.body)

      expect(response.status).to eq(422)
      expect(response_json['errors']['share']).to eq(["can't be blank"])
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

      expect(response).to be_success
      expect(deal_member.reload.share).to eq(62)
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
  
  describe 'Audit logs' do
    it 'creates audit logs for deal when deal member was added' do
      expect{
        post :create, deal_id: deal.id, deal_member: { share: 100, user_id: second_user.id }, format: :json
      }.to change(AuditLog, :count).by(3)

      audit_log = deal.audit_logs.last

      expect(audit_log.new_value).to eq second_user.name
      expect(audit_log.type_of_change).to eq 'Member Added'
      expect(audit_log.updated_by).to eq user.id
      expect(audit_log.user_id).to eq second_user.id
    end

    it 'creates audit logs for deal when update deal member share' do
      deal.deal_members.first.update(share: 20)
      put :update, id: deal_member.id, deal_id: deal.id, deal_member: { share: '80' }, format: :json

      audit_log = deal.audit_logs.last

      expect(audit_log.old_value).to eq '60'
      expect(audit_log.new_value).to eq '80'
      expect(audit_log.type_of_change).to eq 'Share Change'
      expect(audit_log.updated_by).to eq user.id
      expect(audit_log.user_id).to eq user.id
    end

    it 'creates audit logs for deal when deal member was deleted' do
      delete :destroy, id: deal_member.id, deal_id: deal.id, format: :json

      audit_log = deal.audit_logs.last

      expect(audit_log.old_value).to eq user.name
      expect(audit_log.type_of_change).to eq 'Member Removed'
      expect(audit_log.updated_by).to eq user.id
      expect(audit_log.user_id).to eq user.id
    end
  end

  private

  def company
    @_company ||= create :company
  end

  def user
    @_user ||= create :user, company: company
  end

  def second_user
    @_second_user ||= create :user, company: company
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
    @_deal_member ||= create :deal_member, deal_id: deal.id, user_id: user.id, share: 60
  end

  def deal
    @_deal ||=
      create(:deal, stage: stage, company: company, creator: user, end_date: Date.new(2016, 6, 29), advertiser: client)
  end
end
