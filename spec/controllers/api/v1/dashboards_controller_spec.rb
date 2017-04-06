require 'rails_helper'

RSpec.describe Api::V1::DashboardsController, type: :controller do
  let(:company) { create :company }
  let(:user) { create :user, company: company }
  let(:parent_team) { create :parent_team, company: company, leader: user }
  let(:time_period) { create :time_period, company: company }
  let(:deal) { create :deal, company: company }
  let!(:deal_member) { create :deal_member, user: user, deal: deal }

  before do
    valid_token_auth user
  end

  describe 'GET #show' do
    it 'returns json for the dashboard' do
      allow(controller).to receive(:time_period).and_return(time_period)
      get :show

      expect(response).to be_success
      expect(json_response['forecast']['amount']).to_not be_nil
      expect(json_response['deals'].length).to eq(1)
    end

    it 'returns a nil forecast if there is no current time_period' do
      get :show

      expect(response).to be_success
      expect(json_response['forecast']).to be_nil
    end
  end
end
