require 'rails_helper'

RSpec.describe Api::V2::DealsController, type: :controller do
  let(:deal_params) { attributes_for(:deal, advertiser_id: advertiser.id, budget: '31000', stage_id: stage.id) }

  before do
    valid_token_auth user
  end

  describe 'GET #index' do
    let!(:leader_deal) { create :deal, company: company, advertiser: advertiser, stage: stage }
    let!(:deal_member) { create :deal_member, deal: user_deal, user: user  }
    let!(:another_deal_member) { create :deal_member, deal: team_deal, user: another_user  }

    it 'returns a list of deals for the current_user' do
      get :index

      expect(response).to be_success
      expect(json_response.length).to eq(1)
      expect(json_response[0]['id']).to eq(user_deal.id)
    end

    it 'returns a list of the deals for the current_user team' do
      get :index, filter: 'team'

      expect(response).to be_success
      expect(json_response.length).to eq(2)
    end

    it 'returns a list of deals for the current_user company if they are a leader' do
      team.update_attributes(leader: user)

      get :index, filter: 'company'

      expect(response).to be_success
      expect(json_response.length).to eq(3)
    end
  end

  describe 'GET #pipeline_by_stages' do
    let!(:leader_deal) { create :deal, company: company, advertiser: advertiser, stage: stage }
    let!(:deal_member) { create :deal_member, deal: user_deal, user: user  }
    let!(:another_deal_member) { create :deal_member, deal: team_deal, user: another_user  }

    let(:params) { {} }

    subject { get :pipeline_by_stages, params }

    context 'when filter param is absent' do
      it 'returns a list of deals for the current_user' do
        subject

        expect(response).to be_success
        expect(json_response[0]['stage_id']).to eq stage.id
        expect(json_response[0]['deals'].length).to eq(1)
        expect(json_response[0]['deals'][0]['id']).to eq(user_deal.id)
      end
    end

    context 'when filter param is set to team' do
      let(:params) { { filter: 'team' } }

      it 'returns a list of the deals for the current_user team' do
        subject

        expect(response).to be_success
        expect(json_response[0]['stage_id']).to eq stage.id
        expect(json_response[0]['deals'].length).to eq(2)
      end
    end

    context 'when filter param is set to company' do
      let(:params) { { filter: 'company' } }

      before { team.update(leader: user) }

      it 'returns a list of deals for the current_user company' do
        subject

        expect(response).to be_success
        expect(json_response[0]['stage_id']).to eq stage.id
        expect(json_response[0]['deals'].length).to eq(3)
      end
    end


    context 'when name param is set' do
      let(:params) { { name: leader_deal.name } }

      it 'returns deals fitting to name param' do
        subject

        expect(response).to be_success
        expect(json_response[0]['stage_id']).to eq stage.id
        expect(json_response[0]['deals'][0]['id']).to eq leader_deal.id
      end
    end

    context 'when year param is set' do
      let(:params) { { year: leader_deal.start_date.year } }

      it 'returns deals fitting to name param' do
        subject

        expect(response).to be_success
        expect(json_response[0]['stage_id']).to eq stage.id
        expect(json_response[0]['deals'].map { |deal| deal['id'] }).to include leader_deal.id
      end
    end
  end

  describe 'POST #create' do
    it 'creates a new deal and returns success' do
      expect do
        post :create, deal: deal_params

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
        post :create, deal: attributes_for(:deal)

        expect(response.status).to eq(422)
        expect(json_response['errors']['advertiser_id']).to eq(["can't be blank"])
        expect(json_response['errors']['stage_id']).to eq(["can't be blank"])
      end.to_not change(Deal, :count)
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
  end

  describe 'DELETE #destroy' do
    let!(:deal) { create :deal, company: company, advertiser: advertiser }

    it 'marks the deal as deleted' do
      delete :destroy, id: deal.id

      expect(response).to be_success
      expect(deal.reload.deleted_at).to_not be_nil
    end
  end

  describe 'GET #won_deals' do
    let(:won_stage) { create(:won_stage) }
    let!(:deal) { create(:deal, stage: won_stage, company: company) }

    before do
      get :won_deals, format: :json
    end

    it 'should be success' do
      expect(response).to be_success
    end

    it 'returns only won deals for current user company' do
      expect(json_response.count).to eq(1)
    end

    context 'response structure' do
      it 'returns proper json structure for deals won objects' do
        expect(json_response[0].keys).to contain_exactly('id',
                                                         'name',
                                                         'stage',
                                                         'budget_loc',
                                                         'curr_cd',
                                                         'start_date',
                                                         'end_date',
                                                         'advertiser',
                                                         'category',
                                                         'agency',
                                                         'team_and_split',
                                                         'creator')
      end

      context 'when won deal with max share user exists' do
        let!(:deal) { create(:deal, :with_max_share_member, stage: won_stage, company: company) }

        it 'returns team and split' do
          expect(json_response[0]['team_and_split'].count).to eq(1)
        end
      end
      context 'when user with min share exists' do
        let!(:deal) { create(:deal, :with_min_share_member, stage: won_stage, company: company) }

        it 'does not return team and split' do
          expect(json_response[0]['team_and_split'].count).to eq(0)
        end
      end
    end
  end

  describe 'GET #find_by_id' do
    it 'return proper deal data' do
      get :find_by_id, id: deal.id

      expect(response).to be_success
      expect(json_response['id']).to eq deal.id
      expect(json_response['name']).to eq deal.name
    end
  end

  private

  def company
    @_company ||= create(:company)
  end

  def stage
    @_stage ||= create(:stage, company: company, position: 1)
  end

  def team
    @_team ||= create(:parent_team, company: company)
  end

  def advertiser
    @_advertiser ||= create(:client, company: company)
  end

  def user
    @_user ||= create(:user, company: company, team: team)
  end

  def another_user
    @_another_user ||= create(:user, company: company, team: team)
  end

  def deal
    @_deal ||= create(:deal, company: company, stage: stage)
  end

  def team_deal
    @_team_deal ||= create(:deal, company: company, advertiser: advertiser, stage: stage)
  end

  def user_deal
    @_user_deal ||= create(:deal, company: company, advertiser: advertiser, stage: stage)
  end
end
