require 'rails_helper'

RSpec.describe Api::WeightedPipelinesController, type: :controller do
  let(:company) { Company.first }
  let(:user) { create :user }
  let(:parent) { create :parent_team }
  let(:child) { create :child_team, parent: parent, leader: user }
  let(:time_period) { create :time_period, start_date: start_date, end_date: end_date }
  let(:client) { create :client }
  let(:stage) { create :stage, probability: 100 }
  let(:member) { create :user, team: child }
  let(:deal_product_budget) { create :deal_product_budget, budget: 2500, start_date: start_date, end_date: '2015-01-31' }
  let(:deal) { create :deal, stage: stage, advertiser: client, start_date: start_date, end_date: end_date }
  let(:product) { create :product, company: company }
  let!(:deal_product) { create :deal_product, deal: deal, deal_product_budgets: [deal_product_budget], product: product }
  let!(:deal_member) { create :deal_member, deal: deal, user: member, share: 100 }

  before do
    sign_in user
  end

  describe 'GET #show' do
    it 'returns json for a member' do
      get :show, { member_id: member.id, format: :json, time_period_id: time_period.id }
      response_json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response_json.length).to eq(1)
      expect(response_json[0]['name']).to eq(deal.name)
      expect(response_json[0]['client_name']).to eq(client.name)
      expect(response_json[0]['probability']).to eq(stage.probability)
      expect(response_json[0]['in_period_amt']).to eq(2500.0)
      expect(response_json[0]['start_date']).to eq(start_date)
    end

    it 'returns json for a team' do
      get :show, { team_id: child.id, format: :json, time_period_id: time_period.id }
      response_json = JSON.parse(response.body)

      expect(response).to be_success
      expect(response_json.length).to eq(1)
      expect(response_json[0]['name']).to eq(deal.name)
      expect(response_json[0]['client_name']).to eq(client.name)
      expect(response_json[0]['probability']).to eq(stage.probability)
      expect(response_json[0]['in_period_amt']).to eq(2500.0)
      expect(response_json[0]['start_date']).to eq(start_date)
    end
  end

  private

  def start_date
    @_start_date ||= '2015-01-01'
  end

  def end_date
    @_end_date ||= '2015-12-31'
  end
end
