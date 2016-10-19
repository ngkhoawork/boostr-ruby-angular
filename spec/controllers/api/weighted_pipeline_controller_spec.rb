require 'rails_helper'

RSpec.describe Api::WeightedPipelinesController, type: :controller do
  let(:company) { Company.first }
  let(:user) { create :user }
  let(:parent) { create :parent_team }
  let(:child) { create :child_team, parent: parent, leader: user }
  let(:time_period) { create :time_period, start_date: "2015-01-01", end_date: "2015-12-31" }
  let(:client) { create :client }
  let(:stage) { create :stage, probability: 100 }
  let(:member) { create :user, team: child }
  let(:deal) { create :deal, stage: stage, advertiser: client, start_date: "2015-01-01", end_date: "2015-12-31"  }
  let!(:deal_member) { create :deal_member, deal: deal, user: member, share: 100 }
  let!(:deal_product_budget) { create_list :deal_product_budget, 4, deal: deal, budget: 2500, start_date: "2015-01-01", end_date: "2015-01-31" }

  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns json for a member' do
      get :show, { member_id: member.id, format: :json, time_period_id: time_period.id }
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
      expect(response_json[0]['name']).to eq(deal.name)
      expect(response_json[0]['client_name']).to eq(client.name)
      expect(response_json[0]['probability']).to eq(stage.probability)
      expect(response_json[0]['in_period_amt']).to eq(100.0)
      expect(response_json[0]['start_date']).to eq('2015-01-01')
    end

    it 'returns json for a team' do
      get :show, { team_id: child.id, format: :json, time_period_id: time_period.id }
      expect(response).to be_success
      response_json = JSON.parse(response.body)
      expect(response_json.length).to eq(1)
      expect(response_json[0]['name']).to eq(deal.name)
      expect(response_json[0]['client_name']).to eq(client.name)
      expect(response_json[0]['probability']).to eq(stage.probability)
      expect(response_json[0]['in_period_amt']).to eq(100.0)
      expect(response_json[0]['start_date']).to eq('2015-01-01')
    end
  end
end
