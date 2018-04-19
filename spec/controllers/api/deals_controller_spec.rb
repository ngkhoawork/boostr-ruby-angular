require 'rails_helper'

describe Api::DealsController, type: :controller do
  let(:company) { create :company }
  let(:team) { create :parent_team, company: company }
  let(:user) { create :user, company: company, team: team }
  let(:advertiser) { create :client, company: company }
  let(:stage) { create :stage, company: company, position: 1 }  
  let(:deal_params) { attributes_for(:deal, advertiser_id: advertiser.id, budget: '31000', stage_id: stage.id) }
  let(:deal) { create :deal, company: company }

  before do
    sign_in user
    User.current = user
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
        expect(json_response['created_by']).to eq(user.id)
        expect(json_response['budget']).to eq('31000.0')
        expect(json_response['advertiser_id']).to eq(advertiser.id)
        expect(json_response['next_steps']).to eq(deal_params[:next_steps])
        expect(json_response['stage_id']).to eq(stage.id)
      end.to change(Deal, :count).by(1)
    end

    it 'returns errors if the deal is invalid' do
      expect do
        post :create, deal: attributes_for(:deal), format: :json

        expect(response.status).to eq(422)
        expect(json_response['errors']['advertiser_id']).to eq(["can't be blank"])
        expect(json_response['errors']['stage_id']).to eq(["can't be blank"])
      end.to_not change(Deal, :count)
    end

    it 'map lead to contact' do
      assignment_rule = create :assignment_rule, company_id: company.id, countries: ['Usa'], states: ['Ny']
      assignment_rule.users << user
      valid_deal_params = deal_params.merge(lead_id: lead.id)

      post :create, deal: valid_deal_params

      expect(Deal.last.lead).to eq lead
    end

    it 'creates deal cusotm field' do
      post :create, deal: deal_params, format: :json

      expect(Deal.last.deal_custom_field).to be_present
    end

    it 'saves deal cusotm field values' do
      post :create, deal: deal_with_cf_params, format: :json

      expect(Deal.last.deal_custom_field.boolean1).to be true
    end
  end

  describe 'GET #show' do
    it 'returns json for a deal, products and deal_product_budgets' do
      get :show, id: deal.id, format: :json
      expect(response).to be_success
    end
  end

  describe 'PUT #update' do
    it 'updates the deal and returns success' do
      put :update, id: deal.id, deal: { start_date: Date.new(2015, 8, 1) }, format: :json
      expect(response).to be_success
    end

    it 'doesn\'t call touch over and over' do
      expect(controller).to receive(:deal).and_return(deal).at_least(:once)
      expect(deal).to_not receive(:touch)

      put :update, id: deal.id, deal: { start_date: Date.new(2015, 8, 1) }, format: :json
      expect(response).to be_success
    end

    it 'creates audit logs for deal when start date was changed' do
      deal = create :deal, company: company

      expect{
        put :update, id: deal.id, deal: { start_date: Date.new(2017, 8, 10) }, format: :json
      }.to change(AuditLog, :count).by(1)

      audit_log = deal.audit_logs.last

      expect(audit_log.old_value).to eq '2015-07-29'
      expect(audit_log.new_value).to eq '2017-08-10'
      expect(audit_log.type_of_change).to eq 'Start Date Change'
      expect(audit_log.updated_by).to eq user.id
    end

    it 'does not create audit logs for deal when start date was not changed' do
      deal = create :deal, company: company

      expect{
        put :update, id: deal.id, deal: { end_date: Date.new(2017, 8, 10) }, format: :json
      }.to_not change(AuditLog, :count)
    end

    it 'saves deal cusotm field values' do
      deal = create :deal, company: company

      put :update, id: deal.id, deal: deal_with_cf_params, format: :json

      expect(Deal.last.deal_custom_field.boolean1).to be true
    end
  end

  describe 'DELETE #destroy' do
    let!(:deal) { create :deal, company: company, advertiser: advertiser }
    let(:won_stage) { create :stage, name: 'Closed Won', probability: 100, open: false, active: true }

    it 'marks the deal as deleted' do
      delete :destroy, id: deal.id, format: :json
      expect(response).to be_success
      expect(deal.reload.deleted_at).to_not be_nil
    end

    it 'prohibits deleting deals with an IO' do
      deal.update(stage: won_stage)
      deal.update_stage
      deal.update_close

      delete :destroy, id: deal.id, format: :json

      expect(response).not_to be_success
      expect(deal.reload.deleted_at).to be_nil
      expect(json_response['errors']['delete']).to eql(['Please delete IO for this deal before deleting'])
    end
  end

  private

  def lead
    @_lead ||= create :lead, company: company
  end

  def company
    @_company ||= create :company
  end

  def deal_with_cf_params
    cf = attributes_for :deal_custom_field, boolean1: true

    deal_params[:deal_custom_field_attributes] = cf

    deal_params
  end
end
